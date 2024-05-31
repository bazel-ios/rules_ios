load("//rules:features.bzl", "feature_names")
load("//rules:providers.bzl", "PrivateHeadersInfo")
load("//rules:transition_support.bzl", "transition_support")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@build_bazel_rules_apple//apple/internal:apple_product_type.bzl", "apple_product_type")
load("@build_bazel_rules_apple//apple/internal:apple_toolchains.bzl", "AppleMacToolsToolchainInfo", "AppleXPlatToolsToolchainInfo")
load("@build_bazel_rules_apple//apple/internal:features_support.bzl", "features_support")
load("@build_bazel_rules_apple//apple/internal:platform_support.bzl", "platform_support")
load("@build_bazel_rules_apple//apple/internal:resource_actions.bzl", "resource_actions")
load("@build_bazel_rules_apple//apple/internal:rule_support.bzl", "rule_support")
load("@build_bazel_rules_apple//apple/internal:swift_support.bzl", "swift_support")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo")

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
    framework_dir = find_framework_dir(outputs)
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

def _merge_root_infoplists(ctx):
    if ctx.attr.infoplists == None or len(ctx.attr.infoplists) == 0:
        return None

    output_plist = ctx.actions.declare_file(
        paths.join("%s-intermediates" % ctx.label.name, "Info.plist"),
    )

    bundle_name = ctx.attr.framework_name
    current_apple_platform = transition_support.current_apple_platform(apple_fragment = ctx.fragments.apple, xcode_config = ctx.attr._xcode_config)
    platform_type = str(current_apple_platform.platform.platform_type)
    apple_mac_toolchain_info = ctx.attr._mac_toolchain[AppleMacToolsToolchainInfo]
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
        platform_prerequisites = platform_prerequisites(ctx, rule_descriptor, platform_type, features),
        plisttool = apple_mac_toolchain_info.plisttool,
        rule_descriptor = rule_descriptor,
        rule_label = ctx.label,
        version = None,
    )

    return output_plist

def _get_direct_public_headers(provider, dep):
    if provider == CcInfo:
        if PrivateHeadersInfo in dep:
            return []
        return dep[provider].compilation_context.direct_public_headers
    elif provider == apple_common.Objc:
        return getattr(dep[provider], "direct_headers", [])
    else:
        fail("Unknown provider " + provider + " only CcInfo and Objc supported")

# Public

def find_framework_dir(outputs):
    for output in outputs:
        prefix = output.path.rsplit(".framework/", 1)[0]
        return prefix + ".framework"
    return None

def platform_prerequisites(ctx, rule_descriptor, platform_type, features):
    # Consider plumbing this in
    deps = getattr(ctx.attr, "deps", None)
    uses_swift = swift_support.uses_swift(deps) if deps else False

    apple_xplat_toolchain_info = ctx.attr._xplat_toolchain[AppleXPlatToolsToolchainInfo]
    version_args = {
        "build_settings": apple_xplat_toolchain_info.build_settings,
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

def get_framework_files(ctx, attr, deps):
    framework_name = attr.framework_name
    bundle_extension = attr.bundle_extension

    # declare framework directory
    framework_dir = "%s/%s.%s" % (attr.name, framework_name, bundle_extension)

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
        if not attr.link_dynamic:
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