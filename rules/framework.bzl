"""Framework rules"""

load("@build_bazel_rules_apple//apple/internal:apple_product_type.bzl", "apple_product_type")
load("@build_bazel_rules_apple//apple:providers.bzl", "AppleBundleInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo", "swift_common")
load("//rules:library.bzl", "PrivateHeadersInfo", "apple_library")
load("//rules:transition_support.bzl", "transition_support")
load("//rules:providers.bzl", "FrameworkInfo")
load("//rules/framework:vfs_overlay.bzl", "VFSOverlayInfo", "make_vfsoverlay")
load("//rules:features.bzl", "feature_names")

_APPLE_FRAMEWORK_PACKAGING_KWARGS = [
    "visibility",
    "tags",
    "bundle_id",
    "skip_packaging",
]

def apple_framework(name, apple_library = apple_library, **kwargs):
    """Builds and packages an Apple framework.

    Args:
        name: The name of the framework.
        apple_library: The macro used to package sources into a library.
        **kwargs: Arguments passed to the apple_library and apple_framework_packaging rules as appropriate.
    """
    framework_packaging_kwargs = {arg: kwargs.pop(arg) for arg in _APPLE_FRAMEWORK_PACKAGING_KWARGS if arg in kwargs}
    kwargs["enable_framework_vfs"] = kwargs.pop("enable_framework_vfs", True)

    library = apple_library(name = name, **kwargs)
    apple_framework_packaging(
        name = name,
        framework_name = library.namespace,
        transitive_deps = library.transitive_deps,
        vfs = library.import_vfsoverlays,
        deps = library.lib_names,
        platforms = library.platforms,
        platform_type = select({
            "@build_bazel_rules_ios//rules/apple_platform:macos": "macos",
            "@build_bazel_rules_ios//rules/apple_platform:ios": "ios",
            "@build_bazel_rules_ios//rules/apple_platform:tvos": "tvos",
            "@build_bazel_rules_ios//rules/apple_platform:watchos": "watchos",
            "//conditions:default": "",
        }),
        **framework_packaging_kwargs
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

def _framework_packaging(ctx, action, inputs, outputs, manifest = None):
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

def _add_to_dict_if_present(dict, key, value):
    if value:
        dict[key] = value

def _concat(*args):
    arr = []
    for x in args:
        if x:
            arr += x
    return arr

def _get_virtual_framework_info(ctx, framework_files, compilation_context_fields):
    import_vfsoverlays = []
    for dep in ctx.attr.vfs:
        if not VFSOverlayInfo in dep:
            continue
        import_vfsoverlays.append(dep[VFSOverlayInfo].vfs_info)

    # Propagated interface headers - this must encompass all of them
    propagated_interface_headers = []

    # We need to map all the deps here - for both swift headers and others
    fw_dep_vfsoverlays = []
    for dep in ctx.attr.transitive_deps + ctx.attr.deps:
        if not FrameworkInfo in dep:
            continue
        framework_info = dep[FrameworkInfo]
        fw_dep_vfsoverlays.extend(framework_info.vfsoverlay_infos)
        framework_headers = depset(framework_info.headers + framework_info.modulemap + framework_info.private_headers)
        propagated_interface_headers.append(framework_headers)

        # Collect generated headers. consider exposing all required generated
        # headers in respective providers: -Swift, modulemap, -umbrella.h
        if not CcInfo in dep:
            continue
        for h in dep[CcInfo].compilation_context.headers.to_list():
            if h.is_source:
                continue
            propagated_interface_headers.append(depset([h]))

    outputs = framework_files.outputs
    vfs = make_vfsoverlay(
        ctx,
        hdrs = outputs.headers,
        module_map = outputs.modulemap,
        private_hdrs = outputs.private_headers,
        has_swift = len(outputs.swiftmodule) > 0,
        merge_vfsoverlays = fw_dep_vfsoverlays + import_vfsoverlays,
    )

    # Includes interface headers here ( handled in cc_info merge for no virtual )
    compilation_context_fields["headers"] = depset(
        direct = outputs.headers + outputs.private_headers + outputs.modulemap,
        transitive = propagated_interface_headers,
    )

    return FrameworkInfo(
        vfsoverlay_infos = [vfs.vfs_info],
        headers = outputs.headers,
        private_headers = outputs.private_headers,
        modulemap = outputs.modulemap,
        swiftmodule = outputs.swiftmodule,
        swiftdoc = outputs.swiftdoc,
    )

def _get_framework_files(ctx):
    framework_name = ctx.attr.framework_name
    bundle_extension = ctx.attr.bundle_extension

    # declare framework directory
    framework_dir = "%s/%s.%s" % (ctx.attr.name, framework_name, bundle_extension)

    # binaries
    binary_in = []

    # headers
    header_in = []
    header_out = []

    private_header_in = []
    private_header_out = []

    file_map = []

    # modulemap
    modulemap_in = None

    # headermaps
    header_maps = []

    # current build architecture
    arch = ctx.fragments.apple.single_arch_cpu

    # swift specific artifacts
    swiftmodule_in = None
    swiftmodule_out = None
    swiftdoc_in = None
    swiftdoc_out = None

    # AppleBundleInfo fields
    bundle_id = ctx.attr.bundle_id

    # collect files
    for dep in ctx.attr.deps:
        files = dep.files.to_list()
        for file in files:
            if file.is_source:
                continue

            # collect binary files
            if file.path.endswith(".a"):
                binary_in.append(file)

            # collect swift specific files
            if file.path.endswith(".swiftmodule"):
                swiftmodule_in = file
                swiftmodule_out = [paths.join(
                    framework_dir,
                    "Modules",
                    framework_name + ".swiftmodule",
                    arch + ".swiftmodule",
                )]
            if file.path.endswith(".swiftdoc"):
                swiftdoc_in = file
                swiftdoc_out = [paths.join(
                    framework_dir,
                    "Modules",
                    framework_name + ".swiftmodule",
                    arch + ".swiftdoc",
                )]

        if PrivateHeadersInfo in dep:
            for hdr in dep[PrivateHeadersInfo].headers.to_list():
                private_header_in.append(hdr)
                destination = paths.join(framework_dir, "PrivateHeaders", hdr.basename)
                private_header_out.append(destination)

        if apple_common.Objc in dep:
            # collect headers
            has_header = False
            for hdr in dep[apple_common.Objc].direct_headers:
                if hdr.path.endswith((".h", ".hh")):
                    has_header = True
                    header_in.append(hdr)
                    destination = paths.join(framework_dir, "Headers", hdr.basename)
                    header_out.append(destination)

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

    binary_out = None
    modulemap_out = None
    if binary_in:
        binary_out = [
            paths.join(framework_dir, framework_name),
        ]
    if modulemap_in:
        modulemap_out = [
            paths.join(framework_dir, "Modules", "module.modulemap"),
        ]

    virtualize_frameworks = feature_names.virtualize_frameworks in ctx.features
    if not virtualize_frameworks:
        framework_manifest = ctx.actions.declare_file(framework_dir + ".manifest")
    else:
        framework_manifest = None

    # Package each part of the framework separately,
    # so inputs that do not depend on compilation
    # are available before those that do,
    # improving parallelism
    binary_out = _framework_packaging(ctx, "binary", binary_in, binary_out, framework_manifest)
    header_out = _framework_packaging(ctx, "header", header_in, header_out, framework_manifest)
    private_header_out = _framework_packaging(ctx, "private_header", private_header_in, private_header_out, framework_manifest)

    # Instead of creating a symlink of the modulemap, we need to copy it to modulemap_out.
    # It's a hacky fix to guarantee running the clean action before compiling objc files depending on this framework in non-sandboxed mode.
    # Otherwise, stale header files under framework_root will cause compilation failure in non-sandboxed mode.
    modulemap_out = _framework_packaging(ctx, "modulemap", [modulemap_in], modulemap_out, framework_manifest)
    swiftmodule_out = _framework_packaging(ctx, "swiftmodule", [swiftmodule_in], swiftmodule_out, framework_manifest)
    swiftdoc_out = _framework_packaging(ctx, "swiftdoc", [swiftdoc_in], swiftdoc_out, framework_manifest)

    outputs = struct(
        binary = binary_out,
        headers = header_out,
        private_headers = private_header_out,
        modulemap = modulemap_out,
        swiftmodule = swiftmodule_out,
        swiftdoc = swiftdoc_out,
        manifest = framework_manifest,
    )

    inputs = struct(
        binary = binary_in,
        headers = header_in,
        private_headers = private_header_in,
        modulemap = modulemap_in,
        swiftmodule = swiftmodule_in,
        swiftdoc = swiftdoc_in,
    )
    return struct(inputs = inputs, outputs = outputs)

def _get_symlinked_framework_clean_action(ctx, framework_files, compilation_context_fields):
    framework_name = ctx.attr.framework_name

    outputs = framework_files.outputs
    framework_manifest = outputs.manifest
    framework_contents = _concat(
        outputs.binary,
        outputs.modulemap,
        outputs.headers,
        outputs.private_headers,
        outputs.swiftmodule,
        outputs.swiftdoc,
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

def _copy_swiftmodule(ctx, framework_files):
    inputs = framework_files.inputs
    outputs = framework_files.outputs

    # only add a swift module to the SwiftInfo if we've actually got a swiftmodule
    swiftmodule_name = paths.split_extension(inputs.swiftmodule.basename)[0]

    # need to include the swiftmodule here, even though it will be found through the framework search path,
    # since swift_library needs to know that the swiftdoc is an input to the compile action
    swift_module = swift_common.create_swift_module(
        swiftdoc = outputs.swiftdoc[0],
        swiftmodule = outputs.swiftmodule[0],
    )

    if swiftmodule_name != ctx.attr.framework_name:
        # Swift won't find swiftmodule files inside of frameworks whose name doesn't match the
        # module name. It's annoying (since clang finds them just fine), but we have no choice but to point to the
        # original swift module/doc, so that swift can find it.
        swift_module = swift_common.create_swift_module(
            swiftdoc = inputs.swiftdoc,
            swiftmodule = inputs.swiftmodule,
        )

    return [
        # only add the swift module, the objc modulemap is already listed as a header,
        # and it will be discovered via the framework search path
        swift_common.create_module(name = swiftmodule_name, swift = swift_module),
    ]

def _get_merged_objc_provider(ctx):
    # Gather objc provider fields
    # Eventually we need to remove any reference to objc provider
    # and use CcInfo instead, see this issue for more details: https://github.com/bazelbuild/bazel/issues/10674
    objc_provider_fields = {
        "providers": [dep[apple_common.Objc] for dep in ctx.attr.transitive_deps],
    }

    for key in [
        "sdk_dylib",
        "sdk_framework",
        "weak_sdk_framework",
        "imported_library",
        "force_load_library",
        "multi_arch_linked_archives",
        "multi_arch_linked_binaries",
        "multi_arch_dynamic_libraries",
        "source",
        "link_inputs",
        "linkopt",
        "library",
    ]:
        set = depset(
            direct = [],
            transitive = [getattr(dep[apple_common.Objc], key) for dep in ctx.attr.deps],
        )
        _add_to_dict_if_present(objc_provider_fields, key, set)

    return apple_common.new_objc_provider(**objc_provider_fields)

def _apple_framework_packaging_impl(ctx):
    framework_files = _get_framework_files(ctx)
    outputs = framework_files.outputs
    inputs = framework_files.inputs

    # Perform a basic merging of compilation context fields
    compilation_context_fields = {}
    _add_to_dict_if_present(compilation_context_fields, "headers", depset(
        direct = outputs.headers + outputs.private_headers + outputs.modulemap,
    ))

    _add_to_dict_if_present(compilation_context_fields, "defines", depset(
        direct = [],
        transitive = [getattr(dep[CcInfo].compilation_context, "defines") for dep in ctx.attr.deps if CcInfo in dep],
    ))

    swift_info_fields = {
        "swift_infos": [dep[SwiftInfo] for dep in ctx.attr.transitive_deps if SwiftInfo in dep],
    }

    # Compute cc_info and swift_info
    virtualize_frameworks = feature_names.virtualize_frameworks in ctx.features
    if virtualize_frameworks:
        framework_info = _get_virtual_framework_info(ctx, framework_files, compilation_context_fields)
    else:
        framework_info = FrameworkInfo(
            headers = outputs.headers,
            private_headers = outputs.private_headers,
            modulemap = outputs.modulemap,
            swiftmodule = outputs.swiftmodule,
            swiftdoc = outputs.swiftdoc,
        )

        # If not virtualizing the framework - then it runs a "clean"
        _get_symlinked_framework_clean_action(ctx, framework_files, compilation_context_fields)

        # It puts a swiftmodule under the framework in some cases.
        if outputs.swiftmodule:
            swift_info_fields["modules"] = _copy_swiftmodule(ctx, framework_files)

    cc_info_provider = CcInfo(
        compilation_context = cc_common.create_compilation_context(
            **compilation_context_fields
        ),
    )

    if virtualize_frameworks:
        cc_info = cc_common.merge_cc_infos(direct_cc_infos = [cc_info_provider])
    else:
        dep_cc_infos = [dep[CcInfo] for dep in ctx.attr.transitive_deps if CcInfo in dep]
        cc_info = cc_common.merge_cc_infos(direct_cc_infos = [cc_info_provider], cc_infos = dep_cc_infos)

    # Build out the default info provider
    out_files = []
    out_files.extend(outputs.binary)
    out_files.extend(outputs.swiftmodule)
    out_files.extend(outputs.headers)
    out_files.extend(outputs.private_headers)
    out_files.extend(outputs.modulemap)
    default_info = DefaultInfo(files = depset(out_files))

    current_apple_platform = transition_support.current_apple_platform(ctx.fragments.apple, ctx.attr._xcode_config)
    return [
        framework_info,
        _get_merged_objc_provider(ctx),
        cc_info,
        swift_common.create_swift_info(**swift_info_fields),
        default_info,
        AppleBundleInfo(
            archive = None,
            archive_root = None,
            binary = outputs.binary[0] if outputs.binary else None,
            bundle_id = ctx.attr.bundle_id,
            bundle_name = ctx.attr.framework_name,
            bundle_extension = ctx.attr.bundle_extension,
            entitlements = None,
            infoplist = None,
            minimum_os_version = str(current_apple_platform.target_os_version),
            platform_type = str(current_apple_platform.platform.platform_type),
            product_type = ctx.attr._product_type,
            uses_swift = outputs.swiftmodule != None,
        ),
    ]

apple_framework_packaging = rule(
    implementation = _apple_framework_packaging_impl,
    cfg = transition_support.apple_rule_transition,
    fragments = ["apple"],
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
            cfg = apple_common.multi_arch_split,
            doc =
                """Objc or Swift rules to be packed by the framework rule
""",
        ),
        "vfs": attr.label_list(
            mandatory = False,
            cfg = apple_common.multi_arch_split,
            doc =
                """Additional VFS for the framework to export
""",
        ),
        "transitive_deps": attr.label_list(
            mandatory = True,
            doc =
                """Deps of the deps
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
- "private_header"
- "swiftmodule"
- "swiftdoc"
            """,
        ),
        "_framework_packaging": attr.label(
            cfg = "host",
            default = Label(
                "//rules/framework:framework_packaging",
            ),
            executable = True,
        ),
        "_headermap_builder": attr.label(
            executable = True,
            cfg = "host",
            default = Label(
                "//rules/hmap:hmaptool",
            ),
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
        "_product_type": attr.string(default = apple_product_type.static_framework),
        # TODO: allow customizing binary type between dynamic/static
        #         "binary_type": attr.string(
        #             default = "dylib",
        #         ),
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
    },
    doc = "Packages compiled code into an Apple .framework package",
)
