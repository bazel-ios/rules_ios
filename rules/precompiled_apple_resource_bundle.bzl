"""
This provides a resource bundle implementation that builds the resource bundle
only once
NOTE: This rule only exists because of this issue
https://github.com/bazelbuild/rules_apple/issues/319
if this is ever fixed in bazel it should be removed
"""

load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@build_bazel_apple_support//lib:apple_support.bzl", "apple_support")
load("@build_bazel_rules_apple//apple/internal:providers.bzl", "new_appleresourcebundleinfo", "new_appleresourceinfo")
load("@build_bazel_rules_apple//apple/internal:apple_product_type.bzl", "apple_product_type")
load("@build_bazel_rules_apple//apple/internal:intermediates.bzl", "intermediates")
load("@build_bazel_rules_apple//apple/internal:partials.bzl", "partials")
load("@build_bazel_rules_apple//apple/internal:platform_support.bzl", "platform_support")
load("@build_bazel_rules_apple//apple/internal:resources.bzl", "resources")
load("@build_bazel_rules_apple//apple/internal:resource_actions.bzl", "resource_actions")
load("@build_bazel_rules_apple//apple/internal:rule_attrs.bzl", "rule_attrs")
load("@build_bazel_rules_apple//apple/internal:apple_toolchains.bzl", "AppleMacToolsToolchainInfo")
load("//rules:transition_support.bzl", "transition_support")
load("//rules:utils.bzl", "bundle_identifier_for_bundle")

_FAKE_BUNDLE_PRODUCT_TYPE_BY_PLATFORM_TYPE = {
    "ios": apple_product_type.application,
    "tvos": apple_product_type.application,
    "watchos": apple_product_type.watch2_application,
}

_DEVICE_FAMILIES_BY_PLATFORM_TYPE = {
    "ios": ["iphone", "ipad"],
    "macos": ["mac"],
    "tvos": ["tv"],
    "visionos": ["vision"],
    "watchos": ["watch"],
}

def _precompiled_apple_resource_bundle_impl(ctx):
    bundle_name = ctx.attr.bundle_name or ctx.label.name

    current_apple_platform = transition_support.current_apple_platform(apple_fragment = ctx.fragments.apple, xcode_config = ctx.attr._xcode_config)
    platform_type = str(current_apple_platform.platform.platform_type)

    platform_prerequisites = platform_support.platform_prerequisites(
        apple_fragment = ctx.fragments.apple,
        config_vars = ctx.var,
        device_families = _DEVICE_FAMILIES_BY_PLATFORM_TYPE[platform_type],
        explicit_minimum_os = None,
        explicit_minimum_deployment_os = None,
        objc_fragment = None,
        platform_type_string = platform_type,
        uses_swift = False,
        xcode_version_config = ctx.attr._xcode_config[apple_common.XcodeVersionConfig],
        features = [],
        build_settings = None,
    )
    partials_args = dict(
        actions = ctx.actions,
        bundle_extension = ctx.attr.bundle_extension,
        bundle_name = ctx.attr.bundle_name,
        environment_plist = ctx.file.environment_plist,
        executable_name = None,
        launch_storyboard = None,
        platform_prerequisites = platform_prerequisites,
        rule_descriptor = struct(
            additional_infoplist_values = None,
            bundle_package_type = "BNDL",
            binary_infoplist = None,
            product_type = _FAKE_BUNDLE_PRODUCT_TYPE_BY_PLATFORM_TYPE.get(platform_type, ctx.attr._product_type),
        ),
        rule_label = ctx.label,
        swift_module = ctx.attr.swift_module or bundle_name,
        version = None,
        include_executable_name = False,
    )

    apple_mac_toolchain_info = ctx.attr._mac_toolchain[AppleMacToolsToolchainInfo]
    partial_output = partial.call(
        partials.resources_partial(
            apple_mac_toolchain_info = apple_mac_toolchain_info,
            resource_deps = ctx.attr.resources,
            top_level_infoplists = resources.collect(
                attr = ctx.attr,
                res_attrs = ["infoplists"],
            ),
            top_level_resources = resources.collect(
                attr = ctx.attr,
                res_attrs = ["resources"],
            ),
            **partials_args
        ),
    )

    # Process the plist ourselves. This is required because
    # include_executable_name defaults to True, which results in iTC rejecting
    # our binary.
    output_plist = ctx.actions.declare_file(
        paths.join("%s-intermediates" % ctx.label.name, "Info.plist"),
    )

    # No need to pass swift_module to merge_root_infoplists
    partials_args.pop("swift_module")
    resource_actions.merge_root_infoplists(
        bundle_id = ctx.attr.bundle_id or bundle_identifier_for_bundle(bundle_name),
        input_plists = ctx.files.infoplists,
        output_pkginfo = None,
        output_plist = output_plist,
        output_discriminator = "bundle",
        plisttool = apple_mac_toolchain_info.plisttool,
        **partials_args
    )

    # This is a list of files to pass to bundletool using its format, this has
    # a struct with a src and dest mapping that bundle tool uses to copy files
    # https://github.com/bazelbuild/rules_apple/blob/d29df97b9652e0442ebf21f1bc0e04921b584f76/tools/bundletool/bundletool_experimental.py#L29-L35
    control_files = []
    input_files = []
    output_files = []
    output_bundle_dir = ctx.actions.declare_directory(paths.join(ctx.attr.name, bundle_name + ctx.attr.bundle_extension))

    # Need getattr since the partial_ouput struct will be empty when there are no resources.
    # Even so, we want to generate a resource bundle for compatibility.
    # TODO: add an attr to allow skipping when there are no resources entirely
    bundle_files = getattr(partial_output, "bundle_files", [])

    # `target_location` is a special identifier that tells you in a generic way
    # where the resource should end up. This corresponds to:
    # https://github.com/bazelbuild/rules_apple/blob/d29df97b9652e0442ebf21f1bc0e04921b584f76/apple/internal/processor.bzl#L107-L119
    # in this use case both "resource" and "content" correspond to the root
    # directory of the final Foo.bundle/
    #
    # `parent` is the directory the resource should be nested in
    # (under `target_location`) for example Base.lproj would be the parent for
    # a Localizable.strings file. If there is no `parent`, put it in the root
    #
    # `sources` is a depset of files or directories that we need to copy into
    # the bundle. If it's a directory this likely means the compiler could
    # output any number of files (like ibtool from a storyboard) and all the
    # contents should be copied to the bundle (this is handled by bundletool)
    for target_location, parent, sources in bundle_files:
        sources_list = sources.to_list()
        parent_output_directory = parent or ""
        if target_location != "resource" and target_location != "content":
            # For iOS resources these are the only ones we've hit, if we need
            # to add more in the future we should be sure to double check where
            # the need to end up
            fail("Got unexpected target location '{}' for '{}'"
                .format(target_location, sources_list))
        input_files.extend(sources_list)
        for source in sources_list:
            target_path = parent_output_directory
            if not source.is_directory:
                target_path = paths.join(target_path, source.basename)
            output_files.append(target_path)
            control_files.append(struct(src = source.path, dest = target_path))

    # Create a file for bundletool to know what files to copy
    # https://github.com/bazelbuild/rules_apple/blob/d29df97b9652e0442ebf21f1bc0e04921b584f76/tools/bundletool/bundletool_experimental.py#L29-L46
    bundletool_instructions = struct(
        bundle_merge_files = control_files,
        bundle_merge_zips = [],
        output = output_bundle_dir.path,
        code_signing_commands = "",
        post_processor = "",
    )
    bundletool_instructions_file = intermediates.file(
        actions = ctx.actions,
        target_name = ctx.label.name,
        output_discriminator = None,
        file_name = "bundletool_actions.json",
    )
    ctx.actions.write(
        output = bundletool_instructions_file,
        content = json.encode(bundletool_instructions),
    )
    bundletool_experimental = apple_mac_toolchain_info.bundletool_experimental

    apple_support.run(
        actions = ctx.actions,
        apple_fragment = platform_prerequisites.apple_fragment,
        executable = bundletool_experimental,
        execution_requirements = {},
        inputs = depset(input_files + [bundletool_instructions_file]),
        mnemonic = "BundleResources",
        tools = [apple_mac_toolchain_info.bundletool_experimental.executable],
        xcode_config = platform_prerequisites.xcode_version_config,
        arguments = [bundletool_instructions_file.path],
        outputs = [output_bundle_dir],
    )

    return [
        new_appleresourceinfo(
            unowned_resources = depset(),
            owners = depset([
                (output_bundle_dir.short_path, ctx.label),
                (output_plist.short_path, ctx.label),
            ]),
            # This is a list of the resources to propagate without changing further
            # In this case the tuple parameters are:
            # 1. The final directory the resources should end up in, ex Foo.bundle
            #    would result in Bar.app/Foo.bundle
            # 2. The Swift module associated with the resources, this isn't
            #    required for us since we don't use customModuleProvider in IB
            # 3. The resources to propagate, in our case this is just the final
            #    Foo.bundle directory that contains our real resources
            unprocessed = [
                (output_bundle_dir.basename, None, depset([output_bundle_dir, output_plist])),
            ],
        ),
        new_appleresourcebundleinfo(),
        apple_common.new_objc_provider(),
        CcInfo(),
    ]

_precompiled_apple_resource_bundle = rule(
    implementation = _precompiled_apple_resource_bundle_impl,
    fragments = ["apple"],
    cfg = transition_support.apple_rule_transition,
    attrs = dicts.add(rule_attrs.common_tool_attrs(), dict(
        infoplists = attr.label_list(
            allow_files = [".plist"],
            default = [
                Label("@build_bazel_rules_ios//rules/library:resource_bundle.plist"),
            ],
        ),
        bundle_name = attr.string(
            mandatory = False,
            doc = "The name of the resource bundle. Defaults to the target name.",
        ),
        bundle_id = attr.string(
            mandatory = False,
            doc = "The bundle identifier of the resource bundle.",
        ),
        swift_module = attr.string(
            mandatory = False,
            doc = "The swift module to use when compiling storyboards, nibs and xibs that contain a customModuleProvider",
        ),
        resources = attr.label_list(
            allow_empty = True,
            allow_files = True,
            doc = "The list of resources to be included in the resource bundle.",
        ),
        bundle_extension = attr.string(
            mandatory = False,
            default = ".bundle",
            doc = "The extension of the resource bundle.",
        ),
        platforms = attr.string_dict(
            mandatory = False,
            default = {},
            doc = """A dictionary of platform names to minimum deployment targets.
If not given, the resource bundle will be built for the platform it inherits from the target that uses
the bundle as a dependency.""",
        ),
        _product_type = attr.string(default = apple_product_type.bundle),
        # This badly named property is required even though this isn't an ipa
        ipa_post_processor = attr.label(
            allow_files = True,
            executable = True,
            cfg = "exec",
        ),
        environment_plist = attr.label(
            allow_single_file = True,
        ),
        _xcode_config = attr.label(
            default = configuration_field(
                name = "xcode_config_label",
                fragment = "apple",
            ),
            doc = "The xcode config that is used to determine the deployment target for the current platform.",
        ),
        _allowlist_function_transition = attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
            doc = "Needed to allow this rule to have an incoming edge configuration transition.",
        ),
        _mac_toolchain = attr.label(
            default = Label("@build_bazel_rules_apple//apple/internal:mac_tools_toolchain"),
            providers = [[AppleMacToolsToolchainInfo]],
            cfg = "exec",
        ),
    )),
)

def precompiled_apple_resource_bundle(**kwargs):
    _precompiled_apple_resource_bundle(
        environment_plist = select({
            "@build_bazel_rules_ios//rules/apple_platform:ios": "@build_bazel_rules_apple//apple/internal:environment_plist_ios",
            "@build_bazel_rules_ios//rules/apple_platform:macos": "@build_bazel_rules_apple//apple/internal:environment_plist_macos",
            "@build_bazel_rules_ios//rules/apple_platform:tvos": "@build_bazel_rules_apple//apple/internal:environment_plist_tvos",
            "@build_bazel_rules_ios//rules/apple_platform:watchos": "@build_bazel_rules_apple//apple/internal:environment_plist_watchos",
        }),
        **kwargs
    )
