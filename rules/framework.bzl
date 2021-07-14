"""Framework rules"""

load("@build_bazel_rules_apple//apple/internal:apple_product_type.bzl", "apple_product_type")
load("@build_bazel_rules_apple//apple:providers.bzl", "AppleBundleInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo", "swift_common")
load("//rules:library.bzl", "PrivateHeadersInfo", "apple_library")
load("//rules:transition_support.bzl", "transition_support")
load("//rules:internal.bzl", "FrameworkInfo")
load("//rules:hmap.bzl", "HeaderMapInfo")
load("//rules/framework:vfs_overlay.bzl", "VFSOverlayInfo", "write_vfs")

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
    library = apple_library(name = name, **kwargs)
    apple_framework_packaging(
        name = name,
        framework_name = library.namespace,
        transitive_deps = library.transitive_deps,
        vfs = library.output_vfs,
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

    if ctx.attr._virtualize:
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

def _apple_framework_packaging_impl(ctx):
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
    infoplist = None
    current_apple_platform = transition_support.current_apple_platform(ctx.fragments.apple, ctx.attr._xcode_config)

    # collect files
    #print("ctx.attr.transitive_deps", ctx.attr.name, ":", ctx.attr.transitive_deps)
    #print("ctx.attr.deps", ctx.attr.name, ":", ctx.attr.deps)
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

    if not ctx.attr._virtualize:
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

    compilation_context_fields = {}
    if not ctx.attr._virtualize:
        framework_root = _find_framework_dir(framework_files)
        if framework_root:
            framework_files = _concat(binary_out, modulemap_out, header_out, private_header_out, swiftmodule_out, swiftdoc_out)
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
                        .add_all(framework_files),
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
            framework_includes = depset(
                direct = [paths.dirname(framework_root)],
            )
        else:
            ctx.actions.write(framework_manifest, "# Empty framework\n")

    # Note: we need to turn of includes inside of rules_swift
    # Potentially, we can piggy back on swift.vfsoverlay
    # swiftmodule_out = []

    # gather objc provider fields
    # Note; this is needed for the framework stuff
    objc_provider_fields = {
        "providers": [dep[apple_common.Objc] for dep in ctx.attr.transitive_deps],
    }

    _add_to_dict_if_present(compilation_context_fields, "headers", depset(
        direct = header_out + private_header_out + modulemap_out,
    ))

    _add_to_dict_if_present(compilation_context_fields, "defines", depset(
        direct = [],
        transitive = [getattr(dep[CcInfo].compilation_context, "defines") for dep in ctx.attr.deps if CcInfo in dep],
    ))
    _add_to_dict_if_present(objc_provider_fields, "module_map", depset(
        direct = modulemap_out,
    ))
    for key in [
        "sdk_dylib",
        "sdk_framework",
        "weak_sdk_framework",
        "imported_library",
        "force_load_library",
        "multi_arch_linked_archives",
        "multi_arch_linked_binaries",
        "multi_arch_dynamic_libraries",
        "link_inputs",
        "linkopt",
        "library",
    ]:
        set = depset(
            direct = [],
            # Note: this seems like an issue
            transitive = [getattr(dep[apple_common.Objc], key) for dep in ctx.attr.deps],
        )
        _add_to_dict_if_present(objc_provider_fields, key, set)

    # gather swift info fields
    swift_info_fields = {
        "swift_infos": [dep[SwiftInfo] for dep in ctx.attr.transitive_deps if SwiftInfo in dep],
    }

    if not ctx.attr._virtualize and swiftmodule_out:
        # only add a swift module to the SwiftInfo if we've actually got a swiftmodule
        swiftmodule_name = paths.split_extension(swiftmodule_in.basename)[0]

        # need to include the swiftmodule here, even though it will be found through the framework search path,
        # since swift_library needs to know that the swiftdoc is an input to the compile action
        swift_module = swift_common.create_swift_module(
            swiftdoc = swiftdoc_out[0],
            swiftmodule = swiftmodule_out[0],
        )

        if swiftmodule_name != framework_name:
            # Swift won't find swiftmodule files inside of frameworks whose name doesn't match the
            # module name. It's annoying (since clang finds them just fine), but we have no choice but to point to the
            # original swift module/doc, so that swift can find it.
            swift_module = swift_common.create_swift_module(
                swiftdoc = swiftdoc_in,
                swiftmodule = swiftmodule_in,
            )

        swift_info_fields["modules"] = [
            # only add the swift module, the objc modulemap is already listed as a header,
            # and it will be discovered via the framework search path
            swift_common.create_module(name = swiftmodule_name, swift = swift_module),
        ]

    # Eventually we need to remove any reference to objc provider
    # and use CcInfo instead, see this issue for more details: https://github.com/bazelbuild/bazel/issues/10674

    unpropagated_cc_infos = []
    direct_headers = []
    hmaps = []
    merge_vfsoverlays = []

    import_vfsoverlays = []
    for dep in ctx.attr.vfs:
        if VFSOverlayInfo in dep:
            import_vfsoverlays.append(dep[VFSOverlayInfo].files)

    # Progated interface headers - this must encompass all of them
    propagated_interface_headers = []
    swift_hdrs = []

    # We need to map all the deps here - for both swift headers and others
    fw_dep_vfsoverlays = []
    for dep in ctx.attr.transitive_deps + ctx.attr.deps:
        if not FrameworkInfo in dep:
            continue
        framework_info = dep[FrameworkInfo]
        fw_dep_vfsoverlays.append(framework_info.vfsoverlay_infos)
        propagated_interface_headers.append(framework_info.framework_headers)

        # Need swiftc gend' headers inside of the VFS
        if CcInfo in dep:
            for h in dep[CcInfo].compilation_context.headers.to_list():
                if "-Swift.h" in h.path:
                    swift_hdrs.append([h])
                    propagated_interface_headers.append(depset([h]))

    vfs_output = ctx.actions.declare_file(ctx.attr.name + "public_vfs.yaml")

    vfs_ret = write_vfs(
        ctx,
        hdrs = header_out,
        module_map = modulemap_out,
        private_hdrs = private_header_out,  # Note: we probably don't want this but some need it
        has_swift = len(swiftmodule_out) > 0,
        vfs_providers = [],
        merge_vfsoverlays = import_vfsoverlays + fw_dep_vfsoverlays,
        vfsoverlay_file = vfs_output,
        merge_tool = ctx.attr.merge_tool,
        extra_vfs_root = None,
    )

    _add_to_dict_if_present(compilation_context_fields, "headers", depset(
        direct = header_out + private_header_out + modulemap_out,
        # Note: this blows up the hmap
        transitive = propagated_interface_headers + import_vfsoverlays + fw_dep_vfsoverlays + [depset([vfs_ret.vfsoverlay_file, vfs_ret.vfsoverlay_file_merged])],
    ))

    cc_info_provider = CcInfo(
        compilation_context = cc_common.create_compilation_context(
            **compilation_context_fields
        ),
    )

    objc_provider = apple_common.new_objc_provider(**objc_provider_fields)

    framework_headers = depset(header_out + modulemap_out + private_header_out)

    out_files = []
    out_files.extend(binary_out)
    out_files.extend(swiftmodule_out)
    out_files.extend(header_out)
    out_files.extend(private_header_out)
    out_files.extend(modulemap_out)

    return [
        FrameworkInfo(
            direct_framework_includes = None,
            cc_info = cc_info_provider,
            cc_info_merged = None,
            unpropagated_cc_infos = unpropagated_cc_infos,
            headermap_infos = depset(transitive = hmaps),

            # Consider propgating only framework ones, or the merged ones,
            # Note: we don't merge the top level VFS here, so we need to propagate the tuple
            # Consider trying to collapse
            vfsoverlay_infos = depset([vfs_ret.vfsoverlay_file, vfs_ret.vfsoverlay_file_merged], transitive = import_vfsoverlays),
            framework_headers = framework_headers,
        ),
        objc_provider,

        # bare minimum to ensure compilation and package framework with modules and headers
        # TODO: we'll need to switch this?
        cc_common.merge_cc_infos(direct_cc_infos = [cc_info_provider]),

        # Switch here?
        # cc_common.merge_cc_infos(direct_cc_infos = [cc_info_provider], cc_infos = [dep[CcInfo] for dep in ctx.attr.transitive_deps if CcInfo in dep]),
        swift_common.create_swift_info(**swift_info_fields),
        DefaultInfo(files = depset(out_files)),
        AppleBundleInfo(
            archive = None,
            archive_root = None,
            binary = binary_out[0] if binary_out else None,
            bundle_id = bundle_id,
            bundle_name = framework_name,
            bundle_extension = bundle_extension,
            entitlements = None,
            infoplist = infoplist,
            minimum_os_version = str(current_apple_platform.target_os_version),
            platform_type = str(current_apple_platform.platform.platform_type),
            product_type = ctx.attr._product_type,
            uses_swift = swiftmodule_out != None,
        ),
    ]

apple_framework_packaging = rule(
    implementation = _apple_framework_packaging_impl,
    cfg = transition_support.apple_rule_transition,
    fragments = ["apple", "objc"],
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
                """Objc or Swift rules to be packed by the framework rule
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
        "_virtualize": attr.bool(
            default = True,
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
        # TODO: consider renaming if we keep this
        "merge_tool": attr.label(executable = True, default = Label("//rules/framework:merge_vfs_overlay"), cfg = "host"),
    },
    doc = "Packages compiled code into an Apple .framework package",
)
