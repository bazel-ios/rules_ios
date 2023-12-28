"""Framework rules"""

load("//rules/framework:vfs_overlay.bzl", "VFSOverlayInfo", "make_vfsoverlay")
load("//rules:features.bzl", "feature_names")
load("//rules:library.bzl", "PrivateHeadersInfo", "apple_library")
load("//rules:plists.bzl", "process_infoplists")
load("//rules:providers.bzl", "AvoidDepsInfo", "FrameworkInfo")
load("//rules:transition_support.bzl", "transition_support")
load("//rules/internal:objc_provider_utils.bzl", "objc_provider_utils")
load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@build_bazel_rules_apple//apple/internal:apple_product_type.bzl", "apple_product_type")
load("@build_bazel_rules_apple//apple/internal:features_support.bzl", "features_support")
load("@build_bazel_rules_apple//apple/internal:linking_support.bzl", "linking_support")
load("@build_bazel_rules_apple//apple/internal:outputs.bzl", "outputs")
load("@build_bazel_rules_apple//apple/internal:partials.bzl", "partials")
load("@build_bazel_rules_apple//apple/internal:platform_support.bzl", "platform_support")
load("@build_bazel_rules_apple//apple/internal:processor.bzl", "processor")
load("@build_bazel_rules_apple//apple/internal:resource_actions.bzl", "resource_actions")
load("@build_bazel_rules_apple//apple/internal:resources.bzl", "resources")
load("@build_bazel_rules_apple//apple/internal:rule_support.bzl", "rule_support")
load("@build_bazel_rules_apple//apple/internal:apple_toolchains.bzl", "AppleMacToolsToolchainInfo", "AppleXPlatToolsToolchainInfo")
load("@build_bazel_rules_apple//apple/internal:swift_support.bzl", "swift_support")
load("@build_bazel_rules_apple//apple/internal/utils:clang_rt_dylibs.bzl", "clang_rt_dylibs")
load("@build_bazel_rules_apple//apple:providers.bzl", "AppleBundleInfo", "IosFrameworkBundleInfo")
load("@rules_apple_api//:providers.bzl", "new_applebundleinfo", "new_iosframeworkbundleinfo")
load("@rules_apple_api//:version.bzl", "apple_api_version")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo", "swift_clang_module_aspect", "swift_common")
load(
    "@build_bazel_rules_apple//apple/internal/aspects:resource_aspect.bzl",
    "apple_resource_aspect",
)
load("//rules:force_load_direct_deps.bzl", "force_load_direct_deps")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

_APPLE_FRAMEWORK_PACKAGING_KWARGS = [
    "visibility",
    "features",
    "frameworks",
    "tags",
    "bundle_id",
    "skip_packaging",
    "link_dynamic",
    "exported_symbols_lists",
]

def apple_framework(
        name,
        apple_library = apple_library,
        infoplists = [],
        infoplists_by_build_setting = {},
        xcconfig = {},
        xcconfig_by_build_setting = {},
        **kwargs):
    """Builds and packages an Apple framework.

    Args:
        name: The name of the framework.
        apple_library: The macro used to package sources into a library.
        infoplists: A list of Info.plist files to be merged into the framework.
        infoplists_by_build_setting: A dictionary of infoplists grouped by bazel build setting.

                                     Each value is applied if the respective bazel build setting
                                     is resolved during the analysis phase.

                                     If '//conditions:default' is not set the value in 'infoplists'
                                     is set as default.
        xcconfig: A dictionary of xcconfigs to be applied to the framework by default.
        xcconfig_by_build_setting: A dictionary of xcconfigs grouped by bazel build setting.

                                   Each value is applied if the respective bazel build setting
                                   is resolved during the analysis phase.

                                   If '//conditions:default' is not set the value in 'xcconfig'
                                   is set as default.
        **kwargs: Arguments passed to the apple_library and apple_framework_packaging rules as appropriate.
    """
    framework_packaging_kwargs = {arg: kwargs.pop(arg) for arg in _APPLE_FRAMEWORK_PACKAGING_KWARGS if arg in kwargs}
    kwargs["enable_framework_vfs"] = kwargs.pop("enable_framework_vfs", True)

    merged_infoplists = None
    if len(infoplists_by_build_setting.values()) > 0 or len(infoplists) > 0:
        merged_infoplists = select(process_infoplists(
            name = name,
            infoplists = infoplists,
            infoplists_by_build_setting = infoplists_by_build_setting,
            xcconfig = xcconfig,
            xcconfig_by_build_setting = xcconfig_by_build_setting,
        ))
    environment_plist = kwargs.pop("environment_plist", select({
        "@build_bazel_rules_ios//rules/apple_platform:ios": "@build_bazel_rules_apple//apple/internal:environment_plist_ios",
        "@build_bazel_rules_ios//rules/apple_platform:macos": "@build_bazel_rules_apple//apple/internal:environment_plist_macos",
        "@build_bazel_rules_ios//rules/apple_platform:tvos": "@build_bazel_rules_apple//apple/internal:environment_plist_tvos",
        "@build_bazel_rules_ios//rules/apple_platform:watchos": "@build_bazel_rules_apple//apple/internal:environment_plist_watchos",
        "//conditions:default": None,
    }))

    testonly = kwargs.pop("testonly", False)

    library = apple_library(
        name = name,
        testonly = testonly,
        xcconfig = xcconfig,
        xcconfig_by_build_setting = xcconfig_by_build_setting,
        **kwargs
    )

    framework_deps = []

    platforms = library.platforms if library.platforms else {}

    # At the time of writing this is still used in the output path
    # computation
    minimum_os_version = select({
        "@build_bazel_rules_ios//rules/apple_platform:ios": platforms.get("ios", ""),
        "@build_bazel_rules_ios//rules/apple_platform:macos": platforms.get("macos", ""),
        "@build_bazel_rules_ios//rules/apple_platform:tvos": platforms.get("tvos", ""),
        "@build_bazel_rules_ios//rules/apple_platform:watchos": platforms.get("watchos", ""),
        "//conditions:default": "",
    })
    platform_type = select({
        "@build_bazel_rules_ios//rules/apple_platform:ios": "ios",
        "@build_bazel_rules_ios//rules/apple_platform:macos": "macos",
        "@build_bazel_rules_ios//rules/apple_platform:tvos": "tvos",
        "@build_bazel_rules_ios//rules/apple_platform:watchos": "watchos",
        "//conditions:default": "",
    })

    # Setup force loading here - only for direct deps / direct libs and when `link_dynamic` is set.
    force_load_name = name + ".force_load_direct_deps"
    force_load_direct_deps(
        name = force_load_name,
        deps = kwargs.get("deps", []) + library.lib_names,
        should_force_load = framework_packaging_kwargs.get("link_dynamic", False),
        testonly = testonly,
        tags = ["manual"],
        minimum_os_version = minimum_os_version,
        platform_type = platform_type,
    )
    framework_deps.append(force_load_name)

    framework_deps += library.lib_names
    apple_framework_packaging(
        name = name,
        framework_name = library.namespace,
        infoplists = merged_infoplists,
        environment_plist = environment_plist,
        transitive_deps = library.transitive_deps,
        vfs = library.import_vfsoverlays,
        deps = framework_deps,
        platforms = platforms,
        private_deps = kwargs.get("private_deps", []),
        library_linkopts = library.linkopts,
        testonly = testonly,
        minimum_os_version = minimum_os_version,
        platform_type = platform_type,
        **framework_packaging_kwargs
    )

def _validate_deps_minimum_os_version(framework_name, minimum_os_version, deps):
    """Validates that deps' minimum_os_versions are not higher than that of this target.
    Note that Swift has already enforced that at compile time, while objective-c doesn't.

    framework_name: the framework name
    minimum_os_version: the minimum os version of this framework
    deps: the deps of this framework
    """

    # TODO @cshi we need a number of fixes to enable this
    if True:
        return

    for dep in deps:
        if AppleBundleInfo in dep:
            dep_bundle_info = dep[AppleBundleInfo]
            dep_min_os_version = apple_common.dotted_version(dep_bundle_info.minimum_os_version)
            if minimum_os_version.compare_to(dep_min_os_version) < 0:
                fail(
                    """A framework target's minimum_os_version must NOT be lower than those of its deps,
                    but framework {} with minimum_os_version {} depends on framework {} with minimum_os_version {}.
                    """.format(framework_name, minimum_os_version, dep_bundle_info.bundle_name, dep_min_os_version),
                )

def _find_framework_dir(outputs):
    for output in outputs:
        prefix = output.path.rsplit(".framework/", 1)[0]
        return prefix + ".framework"
    return None

def _framework_packaging_symlink_headers(ctx, inputs, outputs):
    inputs_by_basename = {input.basename: input for input in inputs}

    # If this check is true it means that multiple inputs have the same 'basename',
    # an additional check is done to see if that was caused by 'action_inputs' containing
    # two different paths to the same file
    #
    # In that case fails with a msg listing the differences found
    if len(inputs_by_basename) != len(inputs):
        inputs_by_basename_paths = [x.path for x in inputs_by_basename.values()]
        inputs_with_duplicated_basename = [x for x in inputs if not x.path in inputs_by_basename_paths]
        if len(inputs_with_duplicated_basename) > 0:
            fail("""
                [Error] Multiple files with the same name exists.\n
                See below for the list of paths found for each basename:\n
                {}
            """.format({x.basename: (x.path, inputs_by_basename[x.basename].path) for x in inputs_with_duplicated_basename}))

    # If no error occurs create symlinks for each output with
    # each input as 'target_file'
    output_input_dict = {output: inputs_by_basename[output.basename] for output in outputs}
    for (output, input) in output_input_dict.items():
        ctx.actions.symlink(output = output, target_file = input)

def _framework_packaging_single(ctx, action, inputs, output, manifest = None):
    outputs = _framework_packaging_multi(ctx, action, inputs, [output], manifest = manifest)
    return outputs[0] if outputs else None

def _framework_packaging_multi(ctx, action, inputs, outputs, manifest = None):
    if not inputs:
        return []
    if inputs == [None]:
        return []

    virtualize_frameworks = feature_names.virtualize_frameworks in ctx.features
    if virtualize_frameworks:
        return inputs

    if action in ctx.attr.skip_packaging:
        return []
    action_inputs = [manifest] + inputs if manifest else inputs
    outputs = [ctx.actions.declare_file(f) for f in outputs]
    framework_name = ctx.attr.framework_name
    framework_dir = _find_framework_dir(outputs)
    args = ctx.actions.args().use_param_file("@%s").set_param_file_format("multiline")
    args.add("--framework_name", framework_name)
    args.add("--framework_root", framework_dir)
    args.add("--action", action)
    args.add_all("--inputs", inputs)
    args.add_all("--outputs", outputs)

    if action in ["header", "private_header"]:
        _framework_packaging_symlink_headers(ctx, inputs, outputs)
    else:
        ctx.actions.run(
            executable = ctx.executable._framework_packaging,
            arguments = [args],
            inputs = action_inputs,
            outputs = outputs,
            mnemonic = "PackagingFramework%s" % action.title().replace("_", ""),
        )

    return outputs

def _compact(args):
    return [item for item in args if item]

def _get_virtual_framework_info(ctx, framework_files, compilation_context_fields, deps, transitive_deps, vfs):
    import_vfsoverlays = [
        dep[VFSOverlayInfo].vfs_info
        for dep in vfs
        if VFSOverlayInfo in dep
    ]

    # Propagated interface headers - this must encompass all of them
    propagated_interface_headers = []

    # We need to map all the deps here - for both swift headers and others
    fw_dep_vfsoverlays = []
    for dep in transitive_deps + deps:
        # Collect transitive headers. For now, this needs to include all of the
        # transitive headers
        if CcInfo in dep:
            compilation_context = dep[CcInfo].compilation_context
            propagated_interface_headers.append(compilation_context.headers)
        if FrameworkInfo in dep:
            framework_info = dep[FrameworkInfo]
            fw_dep_vfsoverlays.extend(framework_info.vfsoverlay_infos)
            framework_headers = depset(framework_info.headers + framework_info.modulemap + framework_info.private_headers)
            propagated_interface_headers.append(framework_headers)

    outputs = framework_files.outputs
    compile_with_xcode = feature_names.compile_with_xcode in ctx.features
    vfs = make_vfsoverlay(
        ctx,
        hdrs = outputs.headers,
        module_map = outputs.modulemaps,
        # We might need to pass in .swiftinterface files here as well
        # esp. if the error is `swift declaration not found` for some module
        swiftmodules = _compact([outputs.swiftmodule, outputs.swiftdoc]),
        private_hdrs = outputs.private_headers,
        has_swift = True if outputs.swiftmodule else False,
        merge_vfsoverlays = [] if compile_with_xcode else (fw_dep_vfsoverlays + import_vfsoverlays),
    )

    # Includes interface headers here ( handled in cc_info merge for no virtual )
    compilation_context_fields["headers"] = depset(
        direct = outputs.headers + outputs.private_headers + outputs.modulemaps,
        transitive = propagated_interface_headers,
    )

    return FrameworkInfo(
        vfsoverlay_infos = [vfs.vfs_info],
        headers = outputs.headers,
        private_headers = outputs.private_headers,
        modulemap = outputs.modulemaps,
        swiftmodule = outputs.swiftmodule,
        swiftdoc = outputs.swiftdoc,
    )

def _get_framework_files(ctx, deps):
    framework_name = ctx.attr.framework_name
    bundle_extension = ctx.attr.bundle_extension

    # declare framework directory
    framework_dir = "%s/%s.%s" % (ctx.attr.name, framework_name, bundle_extension)

    # binaries
    binaries_in = []

    # headers
    headers_in = []
    headers_out = []

    private_headers_in = []
    private_headers_out = []

    # modulemap
    modulemap_in = None

    # current build architecture
    arch = ctx.fragments.apple.single_arch_cpu

    # swift specific artifacts
    swiftmodule_in = None
    swiftmodule_out = None
    swiftinterface_out = None
    swiftinterface_in = None
    swiftdoc_in = None
    swiftdoc_out = None
    infoplist_in = None
    infoplist_out = None
    symbol_graph_in = None
    symbol_graph_out = None

    # collect files
    for dep in deps:
        files = dep.files.to_list()
        for file in files:
            if file.is_source:
                continue

            # collect binary files
            if file.path.endswith(".a"):
                binaries_in.append(file)

            # collect swift specific files
            if file.path.endswith(".swiftmodule"):
                swiftmodule_in = file
                swiftmodule_out = paths.join(
                    framework_dir,
                    "Modules",
                    framework_name + ".swiftmodule",
                    arch + ".swiftmodule",
                )
            if file.path.endswith(".swiftinterface"):
                swiftinterface_in = file
                swiftinterface_out = paths.join(
                    framework_dir,
                    "Modules",
                    framework_name + ".swiftinterface",
                    arch + ".swiftinterface",
                )
            if file.path.endswith(".swiftdoc"):
                swiftdoc_in = file
                swiftdoc_out = paths.join(
                    framework_dir,
                    "Modules",
                    framework_name + ".swiftmodule",
                    arch + ".swiftdoc",
                )

        if PrivateHeadersInfo in dep:
            for hdr in dep[PrivateHeadersInfo].headers.to_list():
                private_headers_in.append(hdr)
                destination = paths.join(framework_dir, "PrivateHeaders", hdr.basename)
                private_headers_out.append(destination)

        has_header = False
        for provider in [CcInfo, apple_common.Objc]:
            if provider in dep:
                for hdr in _get_direct_public_headers(provider, dep):
                    if not hdr.is_directory and hdr.path.endswith((".h", ".hh", ".hpp")):
                        has_header = True
                        headers_in.append(hdr)
                        destination = paths.join(framework_dir, "Headers", hdr.basename)
                        headers_out.append(destination)
                    elif hdr.path.endswith(".modulemap"):
                        modulemap_in = hdr

        # If theres a symbol graph, we need to copy it over
        if dep.output_groups and hasattr(dep.output_groups, "swift_symbol_graph"):
            symbol_graph_in = dep.output_groups.swift_symbol_graph.to_list()[0]
            symbol_graph_out = paths.join(framework_dir, framework_name + ".symbolgraph")

        if not has_header:
            # only thing is the generated module map -- we don't want it
            continue

        if SwiftInfo in dep and dep[SwiftInfo].direct_modules:
            # apple_common.Objc.direct_module_maps is broken coming from swift_library
            # (it contains one level of transitive module maps), so ignore SwiftInfo from swift_library,
            # since it doesn't have a module_map field anyway
            continue

        # collect modulemaps
        for modulemap in dep[apple_common.Objc].direct_module_maps:
            if modulemap.owner == dep.label:
                # module map is generated by the objc_library, and does not come
                # from the attr
                continue
            modulemap_in = modulemap

    binary_out = paths.join(framework_dir, framework_name) if binaries_in else None
    modulemap_out = paths.join(framework_dir, "Modules", "module.modulemap") if modulemap_in else None

    virtualize_frameworks = feature_names.virtualize_frameworks in ctx.features
    if not virtualize_frameworks:
        framework_manifest = ctx.actions.declare_file(framework_dir + ".manifest")
        if not ctx.attr.link_dynamic:
            infoplist_in = _merge_root_infoplists(ctx)
            infoplist_out = paths.join(
                framework_dir,
                "Info.plist",
            )
    else:
        framework_manifest = None

    # Package each part of the framework separately,
    # so inputs that do not depend on compilation
    # are available before those that do,
    # improving parallelism
    binary_out = _framework_packaging_single(ctx, "binary", binaries_in, binary_out, framework_manifest)
    headers_out = _framework_packaging_multi(ctx, "header", headers_in, headers_out, framework_manifest)
    private_headers_out = _framework_packaging_multi(ctx, "private_header", private_headers_in, private_headers_out, framework_manifest)

    # Instead of creating a symlink of the modulemap, we need to copy it to modulemap_out.
    # It's a hacky fix to guarantee running the clean action before compiling objc files depending on this framework in non-sandboxed mode.
    # Otherwise, stale header files under framework_root will cause compilation failure in non-sandboxed mode.
    modulemap_out = _framework_packaging_single(ctx, "modulemap", [modulemap_in], modulemap_out, framework_manifest)
    swiftmodule_out = _framework_packaging_single(ctx, "swiftmodule", [swiftmodule_in], swiftmodule_out, framework_manifest)
    swiftinterface_out = _framework_packaging_single(ctx, "swiftinterface", [swiftinterface_in], swiftinterface_out, framework_manifest)
    swiftdoc_out = _framework_packaging_single(ctx, "swiftdoc", [swiftdoc_in], swiftdoc_out, framework_manifest)
    infoplist_out = _framework_packaging_single(ctx, "infoplist", [infoplist_in], infoplist_out, framework_manifest)
    symbol_graph_out = _framework_packaging_single(ctx, "symbol_graph", [symbol_graph_in], symbol_graph_out, framework_manifest)

    outputs = struct(
        binary = binary_out,
        headers = headers_out,
        infoplist = infoplist_out,
        private_headers = private_headers_out,
        modulemaps = [modulemap_out] if modulemap_out else [],
        swiftmodule = swiftmodule_out,
        swiftdoc = swiftdoc_out,
        swiftinterface = swiftinterface_out,
        manifest = framework_manifest,
        symbol_graph = symbol_graph_out,
    )

    inputs = struct(
        binaries = binaries_in,
        headers = headers_in,
        private_headers = private_headers_in,
        modulemaps = [modulemap_in] if modulemap_in else [],
        swiftmodule = swiftmodule_in,
        swiftdoc = swiftdoc_in,
        swiftinterface = swiftinterface_in,
        symbol_graph = symbol_graph_in,
    )
    return struct(inputs = inputs, outputs = outputs)

def _get_direct_public_headers(provider, dep):
    if provider == CcInfo:
        if PrivateHeadersInfo in dep:
            return []
        return dep[provider].compilation_context.direct_public_headers
    elif provider == apple_common.Objc:
        return getattr(dep[provider], "direct_headers", [])
    else:
        fail("Unknown provider " + provider + " only CcInfo and Objc supported")

def _get_symlinked_framework_clean_action(ctx, framework_files, compilation_context_fields):
    framework_name = ctx.attr.framework_name

    outputs = framework_files.outputs
    framework_manifest = outputs.manifest

    framework_contents = _compact(
        [
            outputs.binary,
            outputs.swiftmodule,
            outputs.swiftdoc,
        ] +
        outputs.modulemaps +
        outputs.headers +
        outputs.private_headers,
    )

    framework_root = _find_framework_dir(framework_contents)
    if framework_root:
        ctx.actions.run(
            executable = ctx.executable._framework_packaging,
            arguments = [
                "--action",
                "clean",
                "--framework_name",
                framework_name,
                "--framework_root",
                framework_root,
                "--inputs",
                ctx.actions.args().use_param_file("%s", use_always = True).set_param_file_format("multiline")
                    .add_all(framework_contents),
                "--outputs",
                framework_manifest.path,
            ],
            outputs = [framework_manifest],
            mnemonic = "CleaningFramework",
            execution_requirements = {
                "local": "True",
            },
        )
        compilation_context_fields["framework_includes"] = depset(
            direct = [paths.dirname(framework_root)],
        )
    else:
        ctx.actions.write(framework_manifest, "# Empty framework\n")

def _create_swiftmodule(attrs):
    kwargs = {}

    # The upstream code will try collect it - it will be None when non existent
    if attrs.symbol_graph:
        kwargs["symbol_graph"] = attrs.symbol_graph

    return swift_common.create_swift_module(
        swiftdoc = attrs.swiftdoc,
        swiftmodule = attrs.swiftmodule,
        swiftinterface = attrs.swiftinterface,
        **kwargs
    )

def _copy_swiftmodule(ctx, framework_files):
    inputs = framework_files.inputs
    outputs = framework_files.outputs

    # only add a swift module to the SwiftInfo if we've actually got a swiftmodule
    swiftmodule_name = paths.split_extension(inputs.swiftmodule.basename)[0]

    # need to include the swiftmodule here, even though it will be found through the framework search path,
    # since swift_library needs to know that the swiftdoc is an input to the compile action
    swift_module = _create_swiftmodule(outputs)

    if swiftmodule_name != ctx.attr.framework_name:
        # Swift won't find swiftmodule files inside of frameworks whose name doesn't match the
        # module name. It's annoying (since clang finds them just fine), but we have no choice but to point to the
        # original swift module/doc, so that swift can find it.
        swift_module = _create_swiftmodule(inputs)

    return [
        # only add the swift module, the objc modulemap is already listed as a header,
        # and it will be discovered via the framework search path
        swift_common.create_module(name = swiftmodule_name, swift = swift_module),
    ]

def _get_merged_swift_info(ctx, framework_files, transitive_deps):
    swift_info_fields = {
        "swift_infos": [dep[SwiftInfo] for dep in transitive_deps if SwiftInfo in dep],
    }
    if framework_files.outputs.swiftmodule:
        swift_info_fields["modules"] = _copy_swiftmodule(ctx, framework_files)
    return swift_common.create_swift_info(**swift_info_fields)

def _merge_root_infoplists(ctx):
    if ctx.attr.infoplists == None or len(ctx.attr.infoplists) == 0:
        return None

    output_plist = ctx.actions.declare_file(
        paths.join("%s-intermediates" % ctx.label.name, "Info.plist"),
    )

    bundle_name = ctx.attr.framework_name
    current_apple_platform = transition_support.current_apple_platform(apple_fragment = ctx.fragments.apple, xcode_config = ctx.attr._xcode_config)
    platform_type = str(current_apple_platform.platform.platform_type)
    apple_mac_toolchain_info = ctx.attr._toolchain[AppleMacToolsToolchainInfo]
    if hasattr(rule_support, "rule_descriptor_no_ctx"):
        descriptor_fn = rule_support.rule_descriptor_no_ctx
    else:
        descriptor_fn = rule_support.rule_descriptor

    rule_descriptor = descriptor_fn(
        platform_type = platform_type,
        product_type = apple_product_type.static_framework,
    )
    features = features_support.compute_enabled_features(
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    resource_actions.merge_root_infoplists(
        actions = ctx.actions,
        bundle_name = bundle_name,
        bundle_id = ctx.attr.bundle_id,
        bundle_extension = ctx.attr.bundle_extension,
        environment_plist = ctx.file.environment_plist,
        input_plists = ctx.files.infoplists,
        launch_storyboard = None,
        output_plist = output_plist,
        output_pkginfo = None,
        output_discriminator = "framework",
        platform_prerequisites = _platform_prerequisites(ctx, rule_descriptor, platform_type, features),
        resolved_plisttool = apple_mac_toolchain_info.resolved_plisttool,
        rule_descriptor = rule_descriptor,
        rule_label = ctx.label,
        version = None,
    )

    return output_plist

def _attrs_for_split_slice(attrs_by_split_slices, split_slice_key):
    if len(attrs_by_split_slices.keys()) == 0:
        return []
    elif len(attrs_by_split_slices.keys()) == 1:
        return attrs_by_split_slices.values()[0]
    else:
        return attrs_by_split_slices[split_slice_key]

def _platform_prerequisites(ctx, rule_descriptor, platform_type, features):
    # Consider plumbing this in
    deps = getattr(ctx.attr, "deps", None)
    uses_swift = swift_support.uses_swift(deps) if deps else False

    apple_xplat_toolchain_info = ctx.attr._xplat_toolchain[AppleXPlatToolsToolchainInfo]
    if apple_api_version == "3.0":
        version_args = {
            "build_settings": apple_xplat_toolchain_info.build_settings,
        }
    else:
        version_args = {
            "disabled_features": ctx.disabled_features,
        }

    return platform_support.platform_prerequisites(
        apple_fragment = ctx.fragments.apple,
        config_vars = ctx.var,
        cpp_fragment = ctx.fragments.cpp,
        device_families = rule_descriptor.allowed_device_families,
        explicit_minimum_deployment_os = ctx.attr.minimum_deployment_os_version,
        explicit_minimum_os = ctx.attr.minimum_os_version,
        features = features,
        objc_fragment = ctx.fragments.objc,
        platform_type_string = platform_type,
        uses_swift = uses_swift,
        xcode_version_config = ctx.attr._xcode_config[apple_common.XcodeVersionConfig],
        **version_args
    )

def _bundle_dynamic_framework(ctx, is_extension_safe, avoid_deps):
    """Packages this as dynamic framework

    Currently, this doesn't include headers or other interface files.
    """
    actions = ctx.actions
    apple_mac_toolchain_info = ctx.attr._toolchain[AppleMacToolsToolchainInfo]
    apple_xplat_toolchain_info = ctx.attr._xplat_toolchain[AppleXPlatToolsToolchainInfo]
    bin_root_path = ctx.bin_dir.path
    bundle_id = ctx.attr.bundle_id
    if not bundle_id:
        # This is generally not expected behavior - if they don't want a
        # processed infoplit its possible, but validate for the common case
        fail("Missing bundle_id: Info.plist actions require one")

    bundle_name = ctx.attr.framework_name
    bundle_extension = ".framework"
    features = features_support.compute_enabled_features(
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )
    label = ctx.label

    # This file is used as part of the rules_apple bundling logic
    archive = actions.declare_file(ctx.attr.name + ".framework.zip")
    predeclared_outputs = struct(archive = archive)

    provisioning_profile = None
    resource_deps = ctx.attr.deps + ctx.attr.transitive_deps + ctx.attr.data
    current_apple_platform = transition_support.current_apple_platform(apple_fragment = ctx.fragments.apple, xcode_config = ctx.attr._xcode_config)
    platform_type = str(current_apple_platform.platform.platform_type)
    if hasattr(rule_support, "rule_descriptor_no_ctx"):
        descriptor_fn = rule_support.rule_descriptor_no_ctx
    else:
        descriptor_fn = rule_support.rule_descriptor
    rule_descriptor = descriptor_fn(
        platform_type = platform_type,
        product_type = apple_product_type.framework,
    )
    platform_prerequisites = _platform_prerequisites(ctx, rule_descriptor, platform_type, features)
    signed_frameworks = []
    if provisioning_profile:
        signed_frameworks = [
            bundle_name + bundle_extension,
        ]
    top_level_resources = resources.collect(
        attr = ctx.attr,
        res_attrs = ["data"],
    )

    extra_linkopts = [
        "-dynamiclib",
        "-Wl,-install_name,@rpath/{name}{extension}/{name}".format(
            extension = bundle_extension,
            name = bundle_name,
        ),
    ]
    if is_extension_safe:
        extra_linkopts.append("-fapplication-extension")

    top_level_infoplists = resources.collect(
        attr = ctx.attr,
        res_attrs = ["infoplists"],
    )
    if apple_api_version == "3.0":
        link_result = linking_support.register_binary_linking_action(
            ctx,
            avoid_deps = avoid_deps,
            entitlements = None,
            exported_symbols_lists = ctx.files.exported_symbols_lists,
            extra_linkopts = extra_linkopts,
            platform_prerequisites = platform_prerequisites,
            stamp = ctx.attr.stamp,
        )
    else:
        link_result = linking_support.register_binary_linking_action(
            ctx,
            avoid_deps = avoid_deps,
            entitlements = None,
            extra_linkopts = extra_linkopts,
            platform_prerequisites = platform_prerequisites,
            stamp = ctx.attr.stamp,
        )

    binary_artifact = link_result.binary
    debug_outputs = linking_support.debug_outputs_by_architecture(link_result.outputs)

    if apple_api_version == "3.0":
        archive_for_embedding = outputs.archive_for_embedding(
            actions = actions,
            bundle_name = bundle_name,
            bundle_extension = bundle_extension,
            label_name = label.name,
            rule_descriptor = rule_descriptor,
            platform_prerequisites = platform_prerequisites,
            predeclared_outputs = predeclared_outputs,
        )
    else:
        archive_for_embedding = outputs.archive_for_embedding(
            actions = actions,
            bundle_name = bundle_name,
            executable_name = bundle_name,
            bundle_extension = bundle_extension,
            label_name = label.name,
            rule_descriptor = rule_descriptor,
            platform_prerequisites = platform_prerequisites,
            predeclared_outputs = predeclared_outputs,
        )

    dep_frameworks = ctx.attr.frameworks

    # TODO(jmarino) - consider how to better handle frameworks of frameworks
    processor_partials = []

    if apple_api_version == "3.0":
        processor_partials.append(
            partials.apple_bundle_info_partial(
                actions = actions,
                bundle_extension = bundle_extension,
                bundle_id = bundle_id,
                bundle_name = bundle_name,
                executable_name = bundle_name,
                label_name = label.name,
                platform_prerequisites = platform_prerequisites,
                predeclared_outputs = predeclared_outputs,
                product_type = apple_product_type.framework,
                rule_descriptor = rule_descriptor,
            ),
        )
    else:
        processor_partials.append(
            partials.apple_bundle_info_partial(
                actions = actions,
                bundle_extension = bundle_extension,
                bundle_id = bundle_id,
                bundle_name = bundle_name,
                executable_name = bundle_name,
                label_name = label.name,
                platform_prerequisites = platform_prerequisites,
                predeclared_outputs = predeclared_outputs,
                product_type = apple_product_type.framework,
            ),
        )

    processor_partials.append(
        partials.binary_partial(
            executable_name = bundle_name,
            actions = actions,
            binary_artifact = binary_artifact,
            bundle_name = bundle_name,
            label_name = label.name,
        ),
    )
    if apple_api_version == "3.0":
        processor_partials.append(
            partials.codesigning_dossier_partial(
                actions = actions,
                apple_mac_toolchain_info = apple_mac_toolchain_info,
                apple_xplat_toolchain_info = apple_xplat_toolchain_info,
                bundle_extension = bundle_extension,
                bundle_location = processor.location.framework,
                bundle_name = bundle_name,
                embed_target_dossiers = False,
                embedded_targets = dep_frameworks,
                label_name = label.name,
                platform_prerequisites = platform_prerequisites,
                predeclared_outputs = predeclared_outputs,
                provisioning_profile = provisioning_profile,
                rule_descriptor = rule_descriptor,
            ),
        )
    else:
        processor_partials.append(
            partials.codesigning_dossier_partial(
                actions = actions,
                apple_mac_toolchain_info = apple_mac_toolchain_info,
                bundle_extension = bundle_extension,
                bundle_location = processor.location.framework,
                bundle_name = bundle_name,
                embed_target_dossiers = False,
                embedded_targets = dep_frameworks,
                label_name = label.name,
                platform_prerequisites = platform_prerequisites,
                provisioning_profile = provisioning_profile,
                rule_descriptor = rule_descriptor,
            ),
        )

    processor_partials.append(
        partials.clang_rt_dylibs_partial(
            actions = actions,
            apple_mac_toolchain_info = apple_mac_toolchain_info,
            binary_artifact = binary_artifact,
            features = features,
            label_name = label.name,
            platform_prerequisites = platform_prerequisites,
            dylibs = clang_rt_dylibs.get_from_toolchain(ctx),
        ),
    )

    if apple_api_version == "1.0":
        processor_partials.append(
            partials.debug_symbols_partial(
                actions = actions,
                rule_label = label,
                bundle_extension = bundle_extension,
                bundle_name = bundle_name,
                debug_dependencies = dep_frameworks,
                dsym_binaries = debug_outputs.dsym_binaries,
                linkmaps = debug_outputs.linkmaps,
                dsym_info_plist_template = apple_mac_toolchain_info.dsym_info_plist_template,
                executable_name = bundle_name,
                platform_prerequisites = platform_prerequisites,
                bin_root_path = bin_root_path,
            ),
        )
    elif apple_api_version == "2.0":
        processor_partials.append(
            partials.debug_symbols_partial(
                actions = actions,
                bundle_extension = bundle_extension,
                bundle_name = bundle_name,
                debug_dependencies = dep_frameworks,
                dsym_binaries = debug_outputs.dsym_binaries,
                linkmaps = debug_outputs.linkmaps,
                dsym_info_plist_template = apple_mac_toolchain_info.dsym_info_plist_template,
                executable_name = bundle_name,
                platform_prerequisites = platform_prerequisites,
            ),
        )
    else:
        processor_partials.append(
            partials.debug_symbols_partial(
                actions = actions,
                bundle_extension = bundle_extension,
                bundle_name = bundle_name,
                debug_dependencies = dep_frameworks,
                dsym_binaries = debug_outputs.dsym_binaries,
                label_name = label.name,
                linkmaps = debug_outputs.linkmaps,
                dsym_info_plist_template = apple_mac_toolchain_info.dsym_info_plist_template,
                platform_prerequisites = platform_prerequisites,
                resolved_plisttool = apple_mac_toolchain_info.resolved_plisttool,
                rule_label = label,
                version = None,
            ),
        )

    processor_partials.append(
        partials.embedded_bundles_partial(
            frameworks = [archive_for_embedding],
            embeddable_targets = dep_frameworks,
            platform_prerequisites = platform_prerequisites,
            signed_frameworks = depset(signed_frameworks),
        ),
    )
    processor_partials.append(
        partials.extension_safe_validation_partial(
            is_extension_safe = is_extension_safe,
            rule_label = label,
            targets_to_validate = dep_frameworks,
        ),
    )

    if apple_api_version == "1.0":
        processor_partials.append(
            partials.framework_provider_partial(
                actions = actions,
                bin_root_path = bin_root_path,
                binary_artifact = binary_artifact,
                bundle_name = bundle_name,
                bundle_only = False,
                objc_provider = link_result.objc,
                rule_label = label,
            ),
        )
    else:
        cc_toolchain = find_cpp_toolchain(ctx)
        cc_features = cc_common.configure_features(
            ctx = ctx,
            cc_toolchain = cc_toolchain,
            language = "objc",
            requested_features = ctx.features,
            unsupported_features = ctx.disabled_features,
        )
        processor_partials.append(
            partials.framework_provider_partial(
                actions = actions,
                bin_root_path = bin_root_path,
                binary_artifact = binary_artifact,
                bundle_name = bundle_name,
                bundle_only = False,
                cc_features = cc_features,
                cc_info = link_result.cc_info,
                cc_toolchain = cc_toolchain,
                objc_provider = link_result.objc,
                rule_label = label,
            ),
        )

    processor_partials.append(
        partials.resources_partial(
            actions = actions,
            apple_mac_toolchain_info = apple_mac_toolchain_info,
            bundle_extension = bundle_extension,
            bundle_id = bundle_id,
            bundle_name = bundle_name,
            environment_plist = ctx.file.environment_plist,
            executable_name = bundle_name,
            launch_storyboard = None,
            platform_prerequisites = platform_prerequisites,
            resource_deps = resource_deps,
            rule_descriptor = rule_descriptor,
            rule_label = label,
            targets_to_avoid = avoid_deps,
            top_level_infoplists = top_level_infoplists,
            top_level_resources = top_level_resources,
            version = None,
            version_keys_required = False,
        ),
    )
    processor_partials.append(
        partials.swift_dylibs_partial(
            actions = actions,
            apple_mac_toolchain_info = apple_mac_toolchain_info,
            binary_artifact = binary_artifact,
            dependency_targets = dep_frameworks,
            label_name = label.name,
            platform_prerequisites = platform_prerequisites,
        ),
    )
    processor_partials.append(
        partials.apple_symbols_file_partial(
            actions = actions,
            binary_artifact = binary_artifact,
            dsym_binaries = debug_outputs.dsym_binaries,
            dependency_targets = dep_frameworks,
            label_name = label.name,
            include_symbols_in_bundle = False,
            platform_prerequisites = platform_prerequisites,
        ),
    )

    if apple_api_version == "3.0":
        process_version_args = {}
    else:
        process_version_args = {
            "executable_name": bundle_name,
        }
    processor_result = processor.process(
        actions = actions,
        apple_mac_toolchain_info = apple_mac_toolchain_info,
        bundle_extension = bundle_extension,
        bundle_name = bundle_name,
        codesign_inputs = [],
        codesignopts = [],
        features = features,
        ipa_post_processor = None,
        partials = processor_partials,
        platform_prerequisites = platform_prerequisites,
        predeclared_outputs = predeclared_outputs,
        process_and_sign_template = apple_mac_toolchain_info.process_and_sign_template,
        apple_xplat_toolchain_info = apple_xplat_toolchain_info,
        provisioning_profile = provisioning_profile,
        rule_descriptor = rule_descriptor,
        rule_label = label,
        **process_version_args
    )

    return struct(
        files = processor_result.output_files,
        providers = [
            new_iosframeworkbundleinfo(),
            OutputGroupInfo(
                **outputs.merge_output_groups(
                    link_result.output_groups,
                    processor_result.output_groups,
                )
            ),
        ] + processor_result.providers,
    )

def _bundle_static_framework(ctx, is_extension_safe, current_apple_platform, outputs):
    """Returns bundle info for a static framework commonly used intra-build"""
    partial_output = partial.call(
        partials.extension_safe_validation_partial(
            is_extension_safe = is_extension_safe,
            rule_label = ctx.label,
            targets_to_validate = ctx.attr.frameworks,
        ),
    )

    # Static packaging - archives are passed from library deps
    return struct(files = depset([]), providers = [
        new_applebundleinfo(
            archive = None,
            archive_root = None,
            binary = outputs.binary,
            bundle_id = ctx.attr.bundle_id,
            bundle_name = ctx.attr.framework_name,
            bundle_extension = ctx.attr.bundle_extension,
            entitlements = None,
            infoplist = outputs.infoplist,
            minimum_os_version = str(current_apple_platform.target_os_version),
            minimum_deployment_os_version = ctx.attr.minimum_deployment_os_version,
            platform_type = str(current_apple_platform.platform.platform_type),
            product_type = apple_product_type.static_framework,
            uses_swift = outputs.swiftmodule != None,
        ),
    ] + partial_output.providers)

def _apple_framework_packaging_impl(ctx):
    # The current build architecture
    arch = ctx.fragments.apple.single_arch_cpu

    # The current Apple platform type, such as iOS, macOS, tvOS, or watchOS
    platform = str(ctx.fragments.apple.single_arch_platform.platform_type)

    # Use 'library_linkopts' to determine if resulting binary should be application extension safe.
    # This allows manual `linkopts` OR `xcconfig` in the upstream `apple_library` implementation
    # to pass in the right value to the packaging step in this rule.
    is_extension_safe = "-fapplication-extension" in ctx.attr.library_linkopts

    # When building with multiple architectures (e.g.,
    # --ios_multi_cpus=x86_64,arm64), we should only pick the slice for the
    # current configuration.
    split_slice_varint = ""
    if platform == "ios" and arch == "arm64" and not ctx.fragments.apple.single_arch_platform.is_device:
        split_slice_varint = "sim_"

    split_slice_key = "{}_{}{}".format(platform, split_slice_varint, arch)
    deps = _attrs_for_split_slice(ctx.split_attr.deps, split_slice_key)
    transitive_deps = _attrs_for_split_slice(ctx.split_attr.transitive_deps, split_slice_key)
    vfs = _attrs_for_split_slice(ctx.split_attr.vfs, split_slice_key)

    current_apple_platform = transition_support.current_apple_platform(apple_fragment = ctx.fragments.apple, xcode_config = ctx.attr._xcode_config)

    # Validates that the minimum_os_version is not lower than those of the deps.
    _validate_deps_minimum_os_version(ctx.attr.framework_name, current_apple_platform.target_os_version, deps + transitive_deps)

    framework_files = _get_framework_files(ctx, deps)
    outputs = framework_files.outputs

    # Perform a basic merging of compilation context fields
    compilation_context_fields = {}
    objc_provider_utils.add_to_dict_if_present(compilation_context_fields, "headers", depset(
        direct = outputs.headers + outputs.private_headers + outputs.modulemaps,
    ))
    objc_provider_utils.add_to_dict_if_present(compilation_context_fields, "defines", depset(
        direct = [],
        transitive = [getattr(dep[CcInfo].compilation_context, "defines") for dep in deps if CcInfo in dep],
    ))
    objc_provider_utils.add_to_dict_if_present(compilation_context_fields, "includes", depset(
        direct = [],
        transitive = [getattr(dep[CcInfo].compilation_context, "includes") for dep in deps if CcInfo in dep],
    ))
    objc_provider_utils.add_to_dict_if_present(compilation_context_fields, "framework_includes", depset(
        direct = [],
        transitive = [getattr(dep[CcInfo].compilation_context, "framework_includes") for dep in deps if CcInfo in dep],
    ))

    # Compute cc_info and swift_info
    virtualize_frameworks = feature_names.virtualize_frameworks in ctx.features
    if virtualize_frameworks:
        framework_info = _get_virtual_framework_info(ctx, framework_files, compilation_context_fields, deps, transitive_deps, vfs)
    else:
        framework_info = FrameworkInfo(
            headers = outputs.headers,
            private_headers = outputs.private_headers,
            modulemap = outputs.modulemaps,
            swiftmodule = outputs.swiftmodule,
            swiftdoc = outputs.swiftdoc,
        )

        # If not virtualizing the framework - then it runs a "clean"
        _get_symlinked_framework_clean_action(ctx, framework_files, compilation_context_fields)

    _migrates_cc_info_linking_info_transition_flag = ctx.attr._migrates_cc_info_linking_info_transition_flag[0]
    _migrates_cc_info_linking_info_transition_provider = _migrates_cc_info_linking_info_transition_flag[BuildSettingInfo].value

    if _migrates_cc_info_linking_info_transition_provider:
        cc_info_provider = CcInfo(
            compilation_context = cc_common.create_compilation_context(
                **compilation_context_fields
            ),
            linking_context = cc_common.merge_cc_infos(
                direct_cc_infos = [],
                cc_infos = [dep[CcInfo] for dep in deps],
            ).linking_context,
        )
    else:
        cc_info_provider = CcInfo(
            compilation_context = cc_common.create_compilation_context(
                **compilation_context_fields
            ),
        )

    if virtualize_frameworks:
        cc_info = cc_common.merge_cc_infos(direct_cc_infos = [cc_info_provider])
    else:
        dep_cc_infos = [dep[CcInfo] for dep in transitive_deps if CcInfo in dep]
        cc_info = cc_common.merge_cc_infos(direct_cc_infos = [cc_info_provider], cc_infos = dep_cc_infos)

    # Propagate the avoid deps information upwards
    avoid_deps = []
    for dep in ctx.attr.transitive_deps:
        if AvoidDepsInfo in dep:
            avoid_deps.extend(dep[AvoidDepsInfo].libraries)
            if dep[AvoidDepsInfo].link_dynamic:
                avoid_deps.append(dep)

    # If we link dynamic - then package it as dynamic
    if ctx.attr.link_dynamic:
        bundle_outs = _bundle_dynamic_framework(ctx, is_extension_safe = is_extension_safe, avoid_deps = avoid_deps)
        avoid_deps_info = AvoidDepsInfo(libraries = depset(avoid_deps + ctx.attr.deps).to_list(), link_dynamic = True)
    else:
        bundle_outs = _bundle_static_framework(ctx, is_extension_safe = is_extension_safe, current_apple_platform = current_apple_platform, outputs = outputs)
        avoid_deps_info = AvoidDepsInfo(libraries = depset(avoid_deps).to_list(), link_dynamic = False)
    swift_info = _get_merged_swift_info(ctx, framework_files, transitive_deps)

    # Build out the default info provider
    out_files = _compact([outputs.binary, outputs.swiftmodule, outputs.infoplist])
    out_files.extend(outputs.headers)
    out_files.extend(outputs.private_headers)
    out_files.extend(outputs.modulemaps)

    default_info = DefaultInfo(files = depset(out_files + bundle_outs.files.to_list()))

    objc_provider = objc_provider_utils.merge_objc_providers(
        providers = [dep[apple_common.Objc] for dep in deps],
        transitive = [dep[apple_common.Objc] for dep in transitive_deps],
    )
    return [
        avoid_deps_info,
        framework_info,
        objc_provider,
        cc_info,
        swift_info,
        default_info,
    ] + bundle_outs.providers

apple_framework_packaging = rule(
    implementation = _apple_framework_packaging_impl,
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    cfg = transition_support.apple_rule_transition,
    fragments = ["apple", "cpp", "objc"],
    output_to_genfiles = True,
    attrs = {
        "framework_name": attr.string(
            mandatory = True,
            doc =
                """Name of the framework, usually the same as the module name
""",
        ),
        "deps": attr.label_list(
            mandatory = True,
            cfg = transition_support.split_transition,
            aspects = [apple_resource_aspect],
            doc =
                """Objc or Swift rules to be packed by the framework rule
""",
        ),
        "private_deps": attr.label_list(
            mandatory = False,
            cfg = transition_support.split_transition,
            aspects = [apple_resource_aspect],
            doc =
                """Objc or Swift private rules to be packed by the framework rule
""",
        ),
        "data": attr.label_list(
            mandatory = False,
            cfg = transition_support.split_transition,
            allow_files = True,
            doc =
                """Objc or Swift rules to be packed by the framework rule
""",
        ),
        "library_linkopts": attr.string_list(
            doc = """
Internal - A list of strings representing extra flags that are passed to the linker for the underlying library.
""",
        ),
        "link_dynamic": attr.bool(
            mandatory = False,
            default = False,
            doc =
                """Weather or not if this framework is dynamic

The default behavior bakes this into the top level app. When false, it's statically linked.
""",
        ),
        "vfs": attr.label_list(
            mandatory = False,
            cfg = transition_support.split_transition,
            doc =
                """Additional VFS for the framework to export
""",
        ),
        "transitive_deps": attr.label_list(
            aspects = [swift_clang_module_aspect],
            mandatory = True,
            cfg = transition_support.split_transition,
            doc =
                """Deps of the deps
""",
        ),
        "infoplists": attr.label_list(
            mandatory = False,
            allow_files = [".plist"],
            doc = "The infoplists for the framework",
        ),
        "environment_plist": attr.label(
            allow_single_file = True,
            doc = """An executable file referencing the environment_plist tool. Used to merge infoplists.
See https://github.com/bazelbuild/rules_apple/blob/master/apple/internal/environment_plist.bzl#L69
            """,
        ),
        "skip_packaging": attr.string_list(
            mandatory = False,
            default = [],
            allow_empty = True,
            doc = """Parts of the framework packaging process to be skipped.
Valid values are:
- "binary"
- "modulemap"
- "header"
- "infoplist"
- "private_header"
- "swiftmodule"
- "swiftdoc"
            """,
        ),
        "_framework_packaging": attr.label(
            cfg = "exec",
            default = Label(
                "//rules/framework:framework_packaging",
            ),
            executable = True,
        ),
        "frameworks": attr.label_list(
            providers = [[AppleBundleInfo, IosFrameworkBundleInfo]],
            doc = """
A list of framework targets (see
[`ios_framework`](https://github.com/bazelbuild/rules_apple/blob/master/doc/rules-ios.md#ios_framework))
that this target depends on.
""",
            cfg = transition_support.split_transition,
        ),
        "_headermap_builder": attr.label(
            executable = True,
            cfg = "exec",
            default = Label(
                "//rules/hmap:hmaptool",
            ),
        ),
        "stamp": attr.int(
            mandatory = False,
            default = 0,
        ),
        "exported_symbols_lists": attr.label_list(
            allow_files = True,
            doc = """
            """,
        ),
        "_child_configuration_dummy": attr.label(
            cfg = transition_support.split_transition,
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
        "bundle_id": attr.string(
            mandatory = False,
            doc = "The bundle identifier of the framework. Currently unused.",
        ),
        "bundle_extension": attr.string(
            mandatory = False,
            default = "framework",
            doc = "The extension of the bundle, defaults to \"framework\".",
        ),
        "platforms": attr.string_dict(
            mandatory = False,
            default = {},
            doc = """A dictionary of platform names to minimum deployment targets.
If not given, the framework will be built for the platform it inherits from the target that uses
the framework as a dependency.""",
        ),
        "_xcode_config": attr.label(
            default = configuration_field(
                name = "xcode_config_label",
                fragment = "apple",
            ),
            doc = "The xcode config that is used to determine the deployment target for the current platform.",
        ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
            doc = "Needed to allow this rule to have an incoming edge configuration transition.",
        ),
        "_toolchain": attr.label(
            default = Label("@build_bazel_rules_apple//apple/internal:mac_tools_toolchain"),
            providers = [[AppleMacToolsToolchainInfo]],
        ),
        "_xplat_toolchain": attr.label(
            default = Label("@build_bazel_rules_apple//apple/internal:xplat_tools_toolchain"),
            providers = [[AppleXPlatToolsToolchainInfo]],
        ),
        "platform_type": attr.string(
            mandatory = False,
            doc =
                """Internal - currently rules_ios uses the dict `platforms`
""",
        ),
        "minimum_os_version": attr.string(
            mandatory = False,
            doc =
                """Internal - currently rules_ios the dict `platforms`
""",
        ),
        "minimum_deployment_os_version": attr.string(
            mandatory = False,
            doc = "The bundle identifier of the framework. Currently unused.",
            default = "",
        ),
        "_xcrunwrapper": attr.label(
            cfg = "exec",
            default = Label("@bazel_tools//tools/objc:xcrunwrapper"),
            executable = True,
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
            doc = """\
The C++ toolchain from which linking flags and other tools needed by the Swift
toolchain (such as `clang`) will be retrieved.
""",
        ),
        "_migrates_cc_info_linking_info_transition_flag": attr.label(
            default = "//rules:migrates_cc_info_linking_info",
            # 1:1 transition
            cfg = transition_support.migrates_cc_info_linking_info_transition,
            doc = """Internal - the flag to check if the compiler supports cc info in dynamic frameworks
""",
        ),
    },
    doc = "Packages compiled code into an Apple .framework package",
)
