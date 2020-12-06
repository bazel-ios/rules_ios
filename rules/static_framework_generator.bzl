"""This file contains rules to build framework binaries from your podfile or cartfile"""

load("@build_bazel_rules_apple//apple:providers.bzl", "AppleResourceInfo")

def static_framework_generator(**kwargs):
    """
    A wrapper around static_framework_generator_test which disables the sandbox

    This rule writes its output to the WORKSPACE, which is a location out of the sandbox:
    in order for bazel to allow that, sandbox must be disabled

    Args:
        **kwargs: same as the parameters for static_framework_generator_test
    """

    static_framework_generator_test(
        tags = ["no-sandbox"],
        **kwargs
    )

################
# Aspect
################

def _get_resource_targets(deps):
    return depset(transitive = _get_attr_values_for_name(deps, _TargetInfo, "owned_resource_targets"))

_TargetInfo = provider()

def _get_attr_values_for_name(deps, provider, field):
    return [
        getattr(dep[provider], field)
        for dep in deps
        if dep and provider in dep
    ]

def _collect_resources_aspect_impl(target, ctx):
    resource_targets = []
    if ctx.rule.kind == "alias":
        actual = getattr(ctx.rule.attr, "actual")
        if actual and _TargetInfo in actual:
            resource_targets += actual[_TargetInfo].resource_targets
    elif _is_resources_target(ctx):
        resource_targets.append(target)

    provider = _make_provider(ctx, resource_targets)
    return [provider]

def _is_top_level_target(ctx):
    return ctx.rule.kind == "apple_framework_packaging"

def _is_resources_target(ctx):
    return ctx.rule.kind == "_precompiled_apple_resource_bundle"

def _make_provider(ctx, resource_targets):
    deps = getattr(ctx.rule.attr, "deps", [])
    transitive_resource_targets = depset(
        resource_targets,
        transitive = _get_attr_values_for_name(deps, _TargetInfo, "transitive_resource_targets"),
    )

    return _TargetInfo(
        transitive_resource_targets = depset([]) if _is_top_level_target(ctx) else transitive_resource_targets,
        owned_resource_targets = transitive_resource_targets if _is_top_level_target(ctx) else depset([]),
    )

_collect_resources_aspect = aspect(
    implementation = _collect_resources_aspect_impl,
    attr_aspects = ["deps", "actual"],
)

################
# Rule
################

def _declare_directory(ctx, framework_name, filename):
    return ctx.actions.declare_directory("%s/%s/%s" % (ctx.label.name, framework_name, filename))

def _declare_resource_bundles(ctx, target):
    resource_bundles = []
    for resource_target in _get_resource_targets([target]).to_list():
        if AppleResourceInfo in resource_target:
            for resource_group in resource_target[AppleResourceInfo].unprocessed:
                resource_files = resource_group[2].to_list()
                if len(resource_files) == 0:
                    continue

                bundle = _declare_directory(ctx, _get_existing_framework_name(target), "resources/%s" % resource_group[0])
                paths_to_copy = " ".join([file.path for file in resource_files])
                ctx.actions.run_shell(
                    outputs = [bundle],
                    inputs = resource_files,
                    command = "ditto $1 $2",
                    arguments = [paths_to_copy, bundle.path],
                )
                resource_bundles.append(bundle)
    return resource_bundles

def _get_existing_framework_path(target):
    existing_framework_files = target.files.to_list()
    if existing_framework_files:
        framework_path = existing_framework_files[0].dirname
        if framework_path.endswith(".framework"):
            return framework_path

    fail("The target %s does not produce any framework" % target.label.name)

def _get_existing_framework_name(target):
    existing_framework_files = target.files.to_list()
    if existing_framework_files:
        subpaths = existing_framework_files[0].dirname.split("/")
        if subpaths:
            framework_name = subpaths[-1]
            if framework_name.endswith(".framework"):
                return framework_name.replace(".framework", "")

    fail("The target %s does not produce any framework" % target.label.name)

def _declare_framework(ctx, target):
    framework_name = _get_existing_framework_name(target)
    return _declare_directory(ctx, framework_name, framework_name + ".framework")

def _make_frameworks(ctx):
    frameworks = []
    for target in ctx.attr.targets:
        framework = _declare_framework(ctx, target)
        resource_bundles = _declare_resource_bundles(ctx, target)

        existing_framework_files = target.files.to_list()
        existing_framework_path = _get_existing_framework_path(target)

        resource_paths = " ".join([bundle.path for bundle in resource_bundles])
        ctx.actions.run_shell(
            outputs = [framework],
            inputs = existing_framework_files + resource_bundles,
            command = 'rsync -a "$1/" "$3"; for resource in $2; do rsync -a "$resource" "$3/Resources"; done',
            arguments = [existing_framework_path, resource_paths, framework.path],
        )
        frameworks.append(framework)
    return frameworks

def _make_destination(ctx):
    if ctx.attr.destination_relative_to_package:
        return ctx.label.package + "/" + ctx.attr.destination_relative_to_package
    else:
        return ctx.attr.destination_relative_to_workspace

def _make_installer(ctx, subpath, files, destination):
    installer = ctx.actions.declare_file(subpath + "/installer.sh")
    ctx.actions.expand_template(
        template = ctx.file._installer_template,
        output = installer,
        substitutions = {
            "$(files)": " ".join(files),
            "$(destination)": destination,
        },
        is_executable = True,
    )
    return installer

def _static_framework_generator_impl(ctx):
    frameworks = _make_frameworks(ctx)
    destination = _make_destination(ctx)
    installer = _make_installer(ctx, ctx.label.name, [framework.path for framework in frameworks], destination)
    return [
        DefaultInfo(
            executable = installer,
            runfiles = ctx.runfiles(files = frameworks),
        ),
    ]

# Making below rule public in order to properly generate its documentation until the
# https://github.com/bazelbuild/stardoc/issues/27 issue is resolved
static_framework_generator_test = rule(
    implementation = _static_framework_generator_impl,
    doc = """\
This generator moves the frameworks artifacts produced by Bazel to a location out of the cache.
It is intended to be used as a tool to ease compatibility with other build systems.

For example, it would be possible to integrate with cocoapods as follows:
1- Build targets with Bazel
2- Use this rule to generate frameworks for them
3- Generate podspec files containing the generated frameworks as vendored_frameworks, so they can be 
   integrated in a cocoapods setup, substituting their source code counterparts (useful to cut build time)
""",
    attrs = {
        "targets": attr.label_list(
            mandatory = True,
            aspects = [_collect_resources_aspect],
            doc = "The list of targets to use for generating the frameworks",
        ),
        "destination_relative_to_workspace": attr.string(
            mandatory = False,
            default = "static_framework_generator",
            doc = "Destination folder for the generated frameworks, relative to the workspace",
        ),
        "destination_relative_to_package": attr.string(
            mandatory = False,
            doc = "Destination folder for the generated frameworks, relative to the package",
        ),
        "_installer_template": attr.label(
            default = Label("//tools/static_framework_generator:installer.sh"),
            allow_single_file = ["sh"],
        ),
    },
    # Ideally this rule would not be a test: it would be an executable to be run with `bazel run`.
    # The problem with `bazel run` is that you can only execute one target per `bazel run` invocation.
    # See: https://github.com/bazelbuild/bazel/issues/10855
    #
    # A workaround is to mark this rule as a test, because `bazel test` allows to execute multiple
    # test targets in paralel. Running `bazel test` once with multiple targets is much faster than
    # running `bazel run` with one target multiple times
    test = True,
)
