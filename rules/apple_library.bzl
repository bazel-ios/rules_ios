"""Implementation of the `apple_library` rule."""

load("//rules/framework:vfs_overlay.bzl", "framework_vfs_overlay", VFS_OVERLAY_FRAMEWORK_SEARCH_PATH = "FRAMEWORK_SEARCH_PATH")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("//rules/internal:objc_provider_utils.bzl", "objc_provider_utils")
load("//rules:providers.bzl", "AvoidDepsInfo", "FrameworkInfo")
load("//rules/framework:vfs_overlay.bzl", "VFSOverlayInfo", "make_vfsoverlay")
load("@build_bazel_rules_swift//swift/internal:attrs.bzl", "swift_common_rule_attrs", "swift_deps_attr", "swift_toolchain_attrs")
load(
    "@build_bazel_rules_swift//swift/internal:build_settings.bzl",
    "PerModuleSwiftCoptSettingInfo",
    "additional_per_module_swiftcopts",
)
load(
    "@build_bazel_rules_swift//swift/internal:compiling.bzl",
    "apple_library_output_map",
    "new_objc_provider",
    "output_groups_from_other_compilation_outputs",
)
load(
    "@build_bazel_rules_swift//swift/internal:feature_names.bzl",
    "SWIFT_FEATURE_EMIT_SWIFTINTERFACE",
    "SWIFT_FEATURE_ENABLE_LIBRARY_EVOLUTION",
)

#load("@build_bazel_rules_swift//swift/internal:linking.bzl", "create_linker_input")
load("@build_bazel_rules_swift//swift/internal:providers.bzl", "SwiftInfo", "SwiftToolchainInfo")
load("@build_bazel_rules_swift//swift/internal:swift_clang_module_aspect.bzl", "swift_clang_module_aspect")
load("@build_bazel_rules_swift//swift/internal:swift_common.bzl", "swift_common")
load(
    "@build_bazel_rules_swift//swift/internal:utils.bzl",
    "compact",
    #"create_cc_info",
    "expand_locations",
    "expand_make_variables",
    "get_providers",
)
load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:sets.bzl", "sets")
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("//rules:hmap.bzl", "hmap")

def _maybe_parse_as_library_copts(srcs):
    """Returns a list of compiler flags depending on `main.swift`'s presence.

    Builds on Apple platforms typically don't use `swift_binary`; they use
    different linking logic (https://github.com/bazelbuild/rules_apple) to
    produce fat binaries and bundles. This means that all such application code
    will typically be in a `apple_library` target, and that includes a possible
    custom main entry point. For this reason, we need to support the creation of
    `apple_library` targets containing a `main.swift` file, which should *not*
    pass the `-parse-as-library` flag to the compiler.

    Args:
        srcs: A list of source files to check for the presence of `main.swift`.

    Returns:
        An empty list if `main.swift` was present in `srcs`, or a list
        containing a single element `"-parse-as-library"` if `main.swift` was
        not present.
    """
    use_parse_as_library = True
    for src in srcs:
        if src.basename == "main.swift":
            use_parse_as_library = False
            break
    return ["-parse-as-library"] if use_parse_as_library else []

def _extend_modulemap(ctx, swift_umbrella_header):
    output = ctx.actions.declare_file(ctx.attr.name + ".extended.modulemap")
    args = ctx.actions.args()
    module_name = ctx.attr.module_name
    module_map = ctx.files.module_map[0]

    args.add("""
module {module_name}.Swift {{
    header "{swift_umbrella_header}"
    requires objc
}}""".format(
        module_name = module_name,
        swift_umbrella_header = swift_umbrella_header.basename,
    ))
    args.add(module_map.path)
    args.add(output)
    ctx.actions.run_shell(
        inputs = [module_map],
        outputs = [output],
        mnemonic = "ExtendModulemap",
        progress_message = "Extending Map %s" % module_name,
        command = "echo \"$1\" | cat \"$2\" - > \"$3\"",
        arguments = [args],
    )
    return output

def _append_headermap_copts(hmap, flag, objc_copts, swift_copts, cc_copts):
    copt = flag + hmap.path
    objc_copts.append(copt)
    cc_copts.append(copt)
    swift_copts.extend(("-Xcc", copt))

def _apple_library_impl(ctx):
    additional_inputs = ctx.files.swiftc_inputs

    # We need to merge the VFS overlays here
    fw_dep_vfsoverlays = []
    for dep in ctx.attr.deps:
        if FrameworkInfo in dep:
            framework_info = dep[FrameworkInfo]
            fw_dep_vfsoverlays.extend(framework_info.vfsoverlay_infos)
        if VFSOverlayInfo in dep:
            fw_dep_vfsoverlays.append(dep[VFSOverlayInfo].vfs_info)

    objc_hdrs = []
    for h in ctx.attr.hdrs:
        if DefaultInfo in h:
            objc_hdrs.extend(h[DefaultInfo].files.to_list())
        else:
            objc_hdrs.append(h)

    if len(ctx.attr.swift_srcs) == 0 and len(ctx.attr.objc_srcs) == 0 and len(ctx.attr.non_arc_srcs) == 0:
        return [
            swift_common.create_swift_info(
                modules = [],
                # Note that private_deps are explicitly omitted here; they should
                # not propagate.
                swift_infos = [],
            ),
            apple_common.new_objc_provider(),
        ]

        #fail(ctx.attr.name + str(objc_hdrs))
        vfs = make_vfsoverlay(
            ctx,
            hdrs = objc_hdrs,
            output = ctx.actions.declare_file(ctx.attr.name + "_swift.yaml"),
            framework_name = ctx.attr.module_name,
            module_map = [ctx.files.module_map[0]] if ctx.files.module_map else [],
            # We might need to pass in .swiftinterface files here as well
            # esp. if the error is `swift declaration not found` for some module
            swiftmodules = [],
            private_hdrs = ctx.files.private_hdrs,
            has_swift = False,
            merge_vfsoverlays = (fw_dep_vfsoverlays),
        )

        return [
            FrameworkInfo(
                vfsoverlay_infos = [vfs.vfs_info],
                modulemap = [ctx.files.module_map[0]] if ctx.files.module_map else [],
                headers = objc_hdrs,
                private_headers = ctx.files.private_hdrs,
                swiftmodule = [],
            ),
            VFSOverlayInfo(
                files = depset([vfs.vfsoverlay_file]),
                vfs_info = vfs.vfs_info,
            ),
            swift_common.create_swift_info(
                modules = [],
                # Note that private_deps are explicitly omitted here; they should
                # not propagate.
                swift_infos = [],
            ),
            apple_common.new_objc_provider(),
        ]

    # These can't use additional_inputs since expand_locations needs targets,
    # not files.
    swift_copts = expand_locations(ctx, ctx.attr.swift_copts, ctx.attr.swiftc_inputs)
    swift_copts = expand_make_variables(ctx, swift_copts, "swift_copts")
    linkopts = expand_locations(ctx, ctx.attr.linkopts, ctx.attr.swiftc_inputs)
    linkopts = expand_make_variables(ctx, linkopts, "linkopts")

    hmap_namespace = ctx.attr.module_name

    # TODO( missing attrs )
    # module_copts = additional_per_module_swiftcopts(
    #    ctx.label,
    #    ctx.attr._per_module_swiftcopt[PerModuleSwiftCoptSettingInfo],
    # )
    module_copts = []
    swift_copts.extend(module_copts)

    # TODO: We may consider adding this here
    extra_features = []

    module_name = ctx.attr.module_name
    if not module_name:
        module_name = swift_common.derive_module_name(ctx.label)

    swift_toolchain = ctx.attr._toolchain[SwiftToolchainInfo]
    feature_configuration = swift_common.configure_features(
        ctx = ctx,
        requested_features = ctx.features + extra_features,
        swift_toolchain = swift_toolchain,
        unsupported_features = ctx.disabled_features,
    )

    # This needs a bit more thought -
    generated_header_name = ctx.attr.generated_header_name
    deps = ctx.attr.deps

    # If a module was created for the generated header, propagate it as well so
    # that it is passed as a module input to upstream compilation actions.
    clang_module = None

    # This is a different VFS than the otherone
    # Note: this needs to go here, in order to virtualize the extended module
    swift_vfs = make_vfsoverlay(
        ctx,
        hdrs = objc_hdrs,
        module_map = [ctx.files.module_map[0]] if ctx.files.module_map else [],
        framework_name = ctx.attr.module_name,
        output = ctx.actions.declare_file(ctx.attr.name + "_swift.yaml"),
        # Empty here
        swiftmodules = [],
        private_hdrs = ctx.files.private_hdrs,
        has_swift = len(ctx.files.swift_srcs) > 0,
        merge_vfsoverlays = fw_dep_vfsoverlays,
    )
    swift_vfs_copts = [
        "-Xfrontend",
        "-vfsoverlay{}".format(swift_vfs.vfsoverlay_file.path),
        "-Xfrontend",
        "-F{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
        "-I{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
        "-Xcc",
        "-ivfsoverlay{}".format(swift_vfs.vfsoverlay_file.path),
        "-Xcc",
        "-F{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
    ]

    private_hdrs_hmap = ctx.actions.declare_file(ctx.attr.name + "_private.hmap")
    hmap.make_hmap(
        actions = ctx.actions,
        headermap_builder = ctx.executable._headermap_builder,
        output = private_hdrs_hmap,
        namespace = hmap_namespace,
        # This might be a bug - we'll feed the direct headers to the hmap
        hdrs_lists = [ctx.files.private_hdrs + ctx.files.hdrs],
    )

    extra_objc_copts = []
    extra_swift_copts = []
    _append_headermap_copts(private_hdrs_hmap, "-I", extra_objc_copts, extra_swift_copts, [])
    _append_headermap_copts(private_hdrs_hmap, "-iquote", extra_objc_copts, extra_swift_copts, [])

    swift_providers = []
    swift_cc_info = None
    swift_objc_provider = None
    swift_default_info_provider = None
    module_context = None
    generated_header_file = None
    swift_objc_infos = []
    swift_objc_link_inputs = []

    # Mixed swift compilation
    if len(ctx.attr.swift_srcs):
        module_context, cc_compilation_outputs, other_compilation_outputs = swift_common.compile(
            actions = ctx.actions,
            additional_inputs = additional_inputs + [
                swift_vfs.vfsoverlay_file,
                private_hdrs_hmap,
            ] + ctx.files.private_hdrs + ctx.files.hdrs + ctx.files.module_map,
            # additional_swift_copts ( hmap ) + swift_copts + framework_vfs_swift_copts +,

            #copts = _maybe_parse_as_library_copts(ctx.files.swift_srcs) +  extra_swift_copts +  swift_copts + swift_vfs_copts,
            # Note: this vfs needs to go first
            copts = _maybe_parse_as_library_copts(ctx.files.swift_srcs) + swift_copts + swift_vfs_copts + extra_swift_copts,
            defines = ctx.attr.defines,
            deps = deps,
            feature_configuration = feature_configuration,
            generated_header_name = generated_header_name,
            module_name = module_name,
            #private_deps = private_deps,
            srcs = ctx.files.swift_srcs,
            swift_toolchain = swift_toolchain,
            target_name = ctx.label.name,
            workspace_name = ctx.workspace_name,
        )

        linking_context, linking_output = (
            swift_common.create_linking_context_from_compilation_outputs(
                actions = ctx.actions,
                additional_inputs = additional_inputs,
                alwayslink = ctx.attr.alwayslink,
                compilation_outputs = cc_compilation_outputs,
                feature_configuration = feature_configuration,
                label = ctx.label,
                linking_contexts = [
                    dep[CcInfo].linking_context
                    for dep in deps + []
                    if CcInfo in dep
                ],
                module_context = module_context,
                swift_toolchain = swift_toolchain,
                user_link_flags = linkopts,
            )
        )
        swift_objc_link_inputs = [linking_output.library_to_link]
        if generated_header_name:
            for file in module_context.clang.compilation_context.direct_headers:
                if file.short_path.endswith(generated_header_name):
                    generated_header_file = file
                    break

        direct_output_files = compact([
            generated_header_file,
            module_context.clang.precompiled_module,
            module_context.swift.swiftdoc,
            module_context.swift.swiftinterface,
            module_context.swift.swiftmodule,
            module_context.swift.swiftsourceinfo,
            linking_output.library_to_link.static_library,
            linking_output.library_to_link.pic_static_library,
        ])

        implicit_deps_providers = swift_toolchain.implicit_deps_providers
        swift_objc_infos = implicit_deps_providers.objc_infos

        swift_default_info_provider = DefaultInfo(
            files = depset(direct_output_files),
        )

        swift_providers = [
            OutputGroupInfo(**output_groups_from_other_compilation_outputs(
                other_compilation_outputs = other_compilation_outputs,
            )),
            coverage_common.instrumented_files_info(
                ctx,
                dependency_attributes = ["deps"],
                extensions = ["swift"],
                source_attributes = ["srcs"],
            ),
            swift_common.create_swift_info(
                modules = [module_context],
                # Note that private_deps are explicitly omitted here; they should
                # not propagate.
                swift_infos = get_providers(deps, SwiftInfo),
            ),
        ]
        swift_cc_info = CcInfo(
            compilation_context = module_context.clang.compilation_context,
            linking_context = linking_context,
        )

        swift_objc_provider = new_objc_provider(
            additional_link_inputs = additional_inputs,
            additional_objc_infos = swift_objc_infos,
            alwayslink = ctx.attr.alwayslink,
            deps = deps,
            feature_configuration = feature_configuration,
            module_context = module_context,
            libraries_to_link = swift_objc_link_inputs,
            user_link_flags = linkopts,
        )

    cc_toolchain = find_cpp_toolchain(ctx)
    cc_feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    # This is a different VFS than the otherone
    # Note: this needs to go here, in order to virtualize the extended module
    module_map = ctx.files.module_map[0] if ctx.files.module_map else None
    if module_map and generated_header_file:
        module_mapo = _extend_modulemap(ctx, generated_header_file)
        module_map = module_mapo

    swiftmodules = [module_context.swift.swiftmodule] if module_context else []
    objc_vfs = make_vfsoverlay(
        ctx,
        hdrs = objc_hdrs + ([generated_header_file] if generated_header_file else []),
        output = ctx.actions.declare_file(ctx.attr.name + "_objc.yaml"),
        module_map = [module_map] if module_map else ctx.files.module_map,
        framework_name = ctx.attr.module_name,
        # We might need to pass in .swiftinterface files here as well
        # esp. if the error is `swift declaration not found` for some module
        swiftmodules = swiftmodules,
        private_hdrs = ctx.files.private_hdrs,
        has_swift = len(ctx.files.swift_srcs) > 0,
        merge_vfsoverlays = fw_dep_vfsoverlays,
        extra_search_paths = None,
    )

    vfs_objc_copts = [
        "-ivfsoverlay{}".format(objc_vfs.vfsoverlay_file.path),
        "-F{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
    ]

    # Note: here we create a generated headermap for the objc library.
    swift_hmap = ctx.actions.declare_file(ctx.attr.name + "gen.hmap")
    hmap.make_hmap(
        actions = ctx.actions,
        headermap_builder = ctx.executable._headermap_builder,
        output = swift_hmap,
        namespace = hmap_namespace,
        # This might be a bug - we'll feed the direct headers to the hmap
        hdrs_lists = [module_context.clang.compilation_context.direct_headers] if module_context else [],
    )
    label = ctx.label

    objc_srcs = []
    for h in ctx.attr.objc_srcs:
        if DefaultInfo in h:
            objc_srcs.extend(h[DefaultInfo].files.to_list())
        else:
            objc_srcs.append(h)

    objc_non_arc_srcs = []

    # TODO: these are smashed as 1 target
    for h in ctx.attr.non_arc_srcs:
        if DefaultInfo in h:
            objc_non_arc_srcs.extend(h[DefaultInfo].files.to_list())
        else:
            objc_non_arc_srcs.append(h)

    objc_cc_info = None
    objc_link_inputs = []
    objc_objc_provider = None
    objc_default_info_provider = None

    if len(objc_srcs) > 0 or len(objc_non_arc_srcs) > 0:
        # TODO: this needs to go here
        # TODO: cc_info - add it
        cc_ctx, cc_compilation_outputs = cc_common.compile(
            srcs = objc_srcs + objc_non_arc_srcs,
            #public_hdrs = ctx.files.hdrs + [
            #],
            #private_hdrs=ctx.files.private_hdrs,
            # Causes an issue if we feed the generated files here
            additional_inputs = ctx.files.private_hdrs + [
                swift_hmap,
                private_hdrs_hmap,
                objc_vfs.vfsoverlay_file,
            ] + ([module_map] if module_map else []) + ctx.files.hdrs + ctx.files.private_hdrs,
            name = ctx.attr.name,
            actions = ctx.actions,
            user_compile_flags = ["-I."] + vfs_objc_copts + [f.replace("\'", "") for f in ctx.attr.objc_copts] + extra_objc_copts + ["-fno-objc-arc"],
            feature_configuration = cc_feature_configuration,
            cc_toolchain = cc_toolchain,
        )

        linking_context, linking_output = (
            cc_common.create_linking_context_from_compilation_outputs(
                actions = ctx.actions,
                additional_inputs = additional_inputs,
                alwayslink = ctx.attr.alwayslink,
                compilation_outputs = cc_compilation_outputs,
                feature_configuration = cc_feature_configuration,
                name = ctx.attr.name + "_objc",
                disallow_static_libraries = False,
                disallow_dynamic_library = True,
                linking_contexts = [
                    dep[CcInfo].linking_context
                    for dep in deps + []
                    if CcInfo in dep
                ],
                cc_toolchain = cc_toolchain,
            )
        )

        link_inputs = []
        if linking_output.library_to_link:
            link_inputs = linking_output.library_to_link.objects

        objc_default_info_provider = DefaultInfo(
            files = depset(link_inputs),
        )

        objc_cc_info = CcInfo(
            compilation_context = cc_ctx,
            linking_context = linking_context,
        )
        objc_objc_provider = apple_common.new_objc_provider(
            link_inputs = depset(link_inputs),
            linkopt = depset([f.path for f in link_inputs]),
        )

    providers = []
    providers.extend(swift_providers)

    # issue with assumptions in rules_ios
    if len(swift_providers) == 0:
        providers.append(SwiftInfo(direct_modules = []))

    providers.append(objc_provider_utils.merge_objc_providers(
        providers = ([swift_objc_provider] if swift_objc_provider else []) +
                    ([objc_objc_provider] if objc_objc_provider else []),
        merge_keys = [
            "sdk_dylib",
            "sdk_framework",
            "weak_sdk_framework",
            "imported_library",
            "force_load_library",
            "source",
            "link_inputs",
            "linkopt",
            "library",
            "providers",
        ],
    ))

    providers.append(FrameworkInfo(
        vfsoverlay_infos = [objc_vfs.vfs_info],
        modulemap = [module_map],
        headers = ctx.files.hdrs,
        private_headers = ctx.files.private_hdrs,
        swiftmodule = swiftmodules[0] if len(swiftmodules) > 0 else [],
    ))

    vfs_cc_info = CcInfo(
        compilation_context = cc_common.create_compilation_context(
            headers = depset([objc_vfs.vfsoverlay_file] + ctx.files.hdrs),
        ),
    )

    cc_info = cc_common.merge_cc_infos(
        cc_infos = [
                       vfs_cc_info,
                   ] + ([swift_cc_info] if swift_cc_info else []) +
                   ([objc_cc_info] if objc_cc_info else []),
    )
    providers.append(cc_info)

    providers.append(VFSOverlayInfo(
        files = depset([objc_vfs.vfsoverlay_file]),
        vfs_info = objc_vfs.vfs_info,
    ))

    providers.append(DefaultInfo(
        files = depset(
            transitive =
                (
                    (swift_default_info_provider.files if swift_default_info_provider else depset()),
                    (objc_default_info_provider.files if objc_default_info_provider else depset()),
                ),
        ),
        runfiles = ctx.runfiles(
            collect_data = True,
            collect_default = True,
            files = ctx.files.data,
        ),
    ))

    return providers

apple_library = rule(
    attrs = dicts.add(
        swift_common_rule_attrs(
            additional_deps_aspects = [],
        ),
        swift_toolchain_attrs(),
        {
            "swift_srcs": attr.label_list(
                allow_empty = True,
                allow_files = ["swift"],
                doc = """\
""",
                flags = ["DIRECT_COMPILE_TIME_INPUT"],
                mandatory = False,
            ),
            "swift_copts": attr.string_list(
                doc = """\
""",
            ),
            "objc_copts": attr.string_list(
                doc = """\
""",
            ),
            "defines": attr.string_list(
                doc = """\
""",
            ),
            "module_name": attr.string(
                doc = """\
""",
            ),
            "swiftc_inputs": attr.label_list(
                allow_files = True,
                doc = """\
""",
            ),
        },
        # Note: updated to take our custom toolchain
        swift_toolchain_attrs(),
        {
            "_headermap_builder": attr.label(
                executable = True,
                cfg = "host",
                default = Label(
                    "//rules/hmap:hmaptool",
                ),
            ),
            "hdrs": attr.label_list(
                allow_files = True,
                mandatory = False,
                doc =
                    """
""",
            ),
            "objc_srcs": attr.label_list(
                allow_files = True,
                mandatory = False,
                doc =
                    """
""",
            ),
            # TODO
            "non_arc_srcs": attr.label_list(
                allow_files = True,
                mandatory = False,
                doc =
                    """
""",
            ),
            "private_hdrs": attr.label_list(
                allow_files = True,
                mandatory = False,
                doc =
                    """
""",
            ),
            "module_map": attr.label(
                allow_files = True,
                mandatory = False,
                doc =
                    """
""",
            ),
            "generated_header_name": attr.string(
                mandatory = False,
                doc =
                    """
""",
            ),
            "generates_header": attr.bool(
                mandatory = False,
                default = True,
                doc =
                    """
""",
            ),
            "deps": swift_deps_attr(
                aspects = [],
                doc = """\
""",
            ),
            "linkopts": attr.string_list(
                doc = """\
""",
            ),
            "alwayslink": attr.bool(
                default = False,
                doc = """\
""",
            ),
            "_cc_toolchain": attr.label(
                default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
                doc = """\
""",
            ),
        },
    ),
    doc = """\
""",
    implementation = _apple_library_impl,
    fragments = ["apple", "cpp", "objc"],
)
