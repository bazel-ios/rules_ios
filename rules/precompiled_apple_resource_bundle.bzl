"""
This provides a resource bundle implementation that builds the resource bundle
only once
NOTE: This rule only exists because of this issue
https://github.com/bazelbuild/rules_apple/issues/319
if this is ever fixed in bazel it should be removed
"""

load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@build_bazel_rules_apple//apple/internal:apple_product_type.bzl", "apple_product_type")
load("@build_bazel_rules_apple//apple/internal:intermediates.bzl", "intermediates")
load("@build_bazel_rules_apple//apple/internal:partials.bzl", "partials")
load("@build_bazel_rules_apple//apple/internal:resource_actions.bzl", "resource_actions")
load("@build_bazel_rules_apple//apple/internal:rule_factory.bzl", "rule_factory")
load("//rules:transition_support.bzl", "transition_support")
load("@build_bazel_rules_apple//apple:providers.bzl", "AppleResourceBundleInfo", "AppleResourceInfo")

_FAKE_BUNDLE_PRODUCT_TYPE_BY_PLATFORM_TYPE = {
    "ios": apple_product_type.application,
    "tvos": apple_product_type.application,
    "watchos": apple_product_type.watch2_application,
}

def _precompiled_apple_resource_bundle_impl(ctx):
    bundle_name = ctx.attr.bundle_name or ctx.label.name

    attr_dict = {}
    for k in dir(ctx.attr):
        if k in ("to_json", "to_proto"):
            continue
        attr_dict[k] = getattr(ctx.attr, k)

    current_apple_platform = transition_support.current_apple_platform(apple_fragment = ctx.fragments.apple, xcode_config = ctx.attr._xcode_config)
    attr_dict["platform_type"] = str(current_apple_platform.platform.platform_type)
    attr_dict["minimum_os_version"] = str(current_apple_platform.target_os_version)
    attr_dict["_product_type"] = _FAKE_BUNDLE_PRODUCT_TYPE_BY_PLATFORM_TYPE.get(attr_dict["platform_type"], ctx.attr._product_type)

    file_dict = {}
    for k in dir(ctx.file):
        if k in ("to_json", "to_proto"):
            continue
        file_dict[k] = getattr(ctx.file, k)

    file_dict["_environment_plist"] = [f for f in ctx.files._environment_plists if f.path.endswith("_{}.plist".format(attr_dict["platform_type"]))][0]

    fake_ctx_dict = {}
    for k in dir(ctx):
        if k in ("aspect_ids", "build_setting_value", "rule", "to_json", "to_proto"):
            continue
        fake_ctx_dict[k] = getattr(ctx, k)
    fake_ctx_dict["attr"] = struct(**attr_dict)
    fake_ctx_dict["file"] = struct(**file_dict)

    # The label of this fake_ctx is used as the swift module associated with storyboards, nibs, xibs
    # and CoreData models.
    # * For storyboards, nibs and xibs: https://github.com/bazelbuild/rules_apple/blob/master/apple/internal/partials/support/resources_support.bzl#L446
    # * For CoreData models: https://github.com/bazelbuild/rules_apple/blob/master/apple/internal/partials/support/resources_support.bzl#L57
    #
    # Such swift module is required in the following cases:
    # 1- When the storyboard, nib or xib contains the value <customModuleProvider="target">.
    # 2- When the CoreData model sets "Current Product Module" for its Module property.
    # If none of above scenarios, the swift module is not important and could be any arbitrary string.
    # For the full context see https://github.com/bazel-ios/rules_ios/issues/113
    #
    # Usage:
    # The most common scenario happens when the bundle name is the same as the corresponding swift module.
    # If that is not the case, it is possible to customize the swift module by explicitly
    # passing a swift_module attr
    fake_ctx_dict["label"] = Label("//fake_package:" + (ctx.attr.swift_module or bundle_name))
    fake_ctx = struct(**fake_ctx_dict)

    partial_output = partial.call(partials.resources_partial(
        top_level_attrs = ["resources"],
    ), fake_ctx)

    # Process the plist ourselves. This is required because
    # include_executable_name defaults to True, which results in iTC rejecting
    # our binary.
    output_plist = ctx.actions.declare_file(
        paths.join("%s-intermediates" % ctx.label.name, "Info.plist"),
    )
    bundle_id = ctx.attr.bundle_id or "com.cocoapods." + bundle_name
    resource_actions.merge_root_infoplists(
        fake_ctx,
        ctx.files.infoplists,
        output_plist,
        None,
        bundle_id = bundle_id,
        include_executable_name = False,
    )

    # This is a list of files to pass to bundletool using its format, this has
    # a struct with a src and dest mapping that bundle tool uses to copy files
    # https://github.com/bazelbuild/rules_apple/blob/d29df97b9652e0442ebf21f1bc0e04921b584f76/tools/bundletool/bundletool_experimental.py#L29-L35
    control_files = []
    input_files = []
    output_files = []
    output_bundle_dir = ctx.actions.declare_directory(paths.join(ctx.attr.name, bundle_name + ".bundle"))

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
        ctx.actions,
        ctx.label.name,
        "bundletool_actions.json",
    )
    ctx.actions.write(
        output = bundletool_instructions_file,
        content = bundletool_instructions.to_json(),
    )
    ctx.actions.run(
        executable = ctx.executable._bundletool_experimental,
        mnemonic = "BundleResources",
        progress_message = "Bundling " + bundle_name,
        inputs = input_files + [bundletool_instructions_file],
        outputs = [output_bundle_dir],
        arguments = [bundletool_instructions_file.path],
    )
    return [
        AppleResourceInfo(
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
        AppleResourceBundleInfo(),
        apple_common.new_objc_provider(),
    ]

precompiled_apple_resource_bundle = rule(
    implementation = _precompiled_apple_resource_bundle_impl,
    fragments = ["apple"],
    cfg = transition_support.apple_rule_transition,
    attrs = dict(
        # This includes all the undocumented tool requirements for this rule
        rule_factory.common_tool_attributes,
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
            default = "bundle",
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
        _environment_plists = attr.label_list(
            allow_files = True,
            default = [
                Label("@build_bazel_rules_apple//apple/internal:environment_plist_ios"),
                Label("@build_bazel_rules_apple//apple/internal:environment_plist_macos"),
                Label("@build_bazel_rules_apple//apple/internal:environment_plist_tvos"),
                Label("@build_bazel_rules_apple//apple/internal:environment_plist_watchos"),
            ],
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
    ),
)
