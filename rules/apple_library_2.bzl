load("@bazel_skylib//lib:sets.bzl", "sets")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftToolchainInfo", "swift_common")
load("//rules:hmap.bzl", "hmap")
load(
    "@bazel_tools//tools/build_defs/cc:action_names.bzl",
    "CPP_LINK_STATIC_LIBRARY_ACTION_NAME",
    "OBJC_COMPILE_ACTION_NAME",
)

_VFS_ROOT = "/__com_github_bazel_ios_rules_ios/framework"

def _uppercase_path_string(s):
    return s.path.upper()

def _apple_library_2_impl(ctx):
    srcs = ctx.files.srcs
    name = ctx.label
    module_name = ctx.attr.module_name or name.name

    private_headers = None
    public_headers = None
    objc_sources = []
    swift_sources = []
    cpp_sources = []
    objc_non_exported_hdrs = []
    objc_private_hdrs = []
    objc_hdrs = []

    for f in sorted(srcs, key = _uppercase_path_string):
        extension = f.extension
        if extension in ("h", "hh"):
            if (private_headers and sets.contains(private_headers, f)) or \
               (public_headers and sets.contains(public_headers, f)):
                pass
            elif public_headers and private_headers:
                objc_non_exported_hdrs.append(f)
            elif public_headers:
                objc_private_hdrs.append(f)
            else:
                objc_hdrs.append(f)
        elif extension in ("m", "mm", "c"):
            objc_sources.append(f)
        elif extension in ("swift",):
            swift_sources.append(f)
        elif extension in ("cc", "cpp"):
            cpp_sources.append(f)
        else:
            fail("Unable to compile %s in %s (ext %s)" % (f, name, extension))

    output_template = "_objs/{name}/{type}/{filename}"

    cc_toolchain = ctx.attr._cc_toolchain[cc_common.CcToolchainInfo]

    cc_feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = [],
        unsupported_features = [],
    )

    object_files = []

    private_hmap = ctx.actions.declare_file(output_template.format(name = ctx.label.name, type = "hmap", filename = "private.hmap"))
    public_hmap = ctx.actions.declare_file(output_template.format(name = ctx.label.name, type = "hmap", filename = "public.hmap"))
    modulemap = ctx.actions.declare_file(output_template.format(name = ctx.label.name, type = "modulemap", filename = "module.modulemap"))
    umbrella_header = ctx.actions.declare_file(output_template.format(name = ctx.label.name, type = "umbrella_header", filename = module_name + "-umbrella.h"))
    vfsoverlay_file = ctx.actions.declare_file(output_template.format(name = ctx.label.name, type = "vfsoverlay", filename = module_name + ".vfxoverlay.yaml"))

    ctx.actions.write(umbrella_header, "\n".join(["#import \"%s\"" % h.basename for h in objc_hdrs]))
    ctx.actions.write(modulemap, """framework module %s {
  umbrella header \"%s\"

  export *
  module * { export * }
}
""" % (module_name, umbrella_header.basename))

    objc_hdrs.append(umbrella_header)

    dep_cc_info = cc_common.merge_cc_infos(cc_infos = [dep[CcInfo] for dep in ctx.attr.deps if CcInfo in dep])

    virtual_header_files = [
        {
            "type": "file",
            "name": header.basename,
            "external-contents": header.path,
        }
        for header in objc_hdrs
    ]

    # These explicit settings ensure that the VFS actually improves search
    # performance.
    vfsoverlay_object = {
        "version": 0,
        "case-sensitive": True,
        "overlay-relative": False,
        "use-external-names": False,
        "roots": [
            {
                "type": "directory",
                "name": _VFS_ROOT,
                "contents": [
                    {"type": "directory", "name": "{}.framework".format(module_name), "contents": [
                        {"type": "directory", "name": "Headers", "contents": virtual_header_files},
                        {"type": "directory", "name": "Modules", "contents": [{"type": "file", "name": "module.modulemap", "external-contents": modulemap.path}]},
                    ]},
                ],
            },
        ],
    }

    # The YAML specification defines it has a superset of JSON, so it is safe to
    # use the built-in `to_json` function here.
    vfsoverlay_yaml = struct(**vfsoverlay_object).to_json()

    ctx.actions.write(
        content = vfsoverlay_yaml,
        output = vfsoverlay_file,
    )

    swift_toolchain = ctx.attr._swift_toolchain[SwiftToolchainInfo]
    swift_features = swift_common.configure_features(ctx = ctx, swift_toolchain = swift_toolchain, requested_features = [], unsupported_features = [])
    swift_compilation = swift_common.compile(
        actions = ctx.actions,
        feature_configuration = swift_features,
        module_name = module_name,
        srcs = swift_sources,
        swift_toolchain = swift_toolchain,
        target_name = ctx.label.name,
        additional_inputs = [vfsoverlay_file, modulemap, umbrella_header] + objc_hdrs,
        bin_dir = None,
        copts = [
            "-Xfrontend",
            "-vfsoverlay{}".format(vfsoverlay_file.path),
            "-F" + _VFS_ROOT,
            "-import-underlying-module",
            "-Xcc",
            "-iquote{}".format(private_hmap.path),
        ],
        defines = [],
        deps = ctx.attr.deps,
        generated_header_name = "{}-Swift.h".format(module_name),
        genfiles_dir = None,
    )
    objc_hdrs.append(swift_compilation.generated_header)
    object_files.extend(swift_compilation.object_files)

    hmap.make_hmap(
        actions = ctx.actions,
        headermap_builder = ctx.executable._headermap_builder,
        output = private_hmap,
        namespace = module_name,
        hdrs_lists = (objc_hdrs,),
    )

    hmap.make_hmap(
        actions = ctx.actions,
        headermap_builder = ctx.executable._headermap_builder,
        output = public_hmap,
        namespace = module_name,
        hdrs_lists = (objc_hdrs,),
    )

    for file in objc_sources:
        output = ctx.actions.declare_file(output_template.format(name = name, type = "objc_arc", filename = file.basename + ".o"))
        compile_variables = cc_common.create_compile_variables(
            cc_toolchain = cc_toolchain,
            feature_configuration = cc_feature_configuration,
            source_file = file.path,
            output_file = output.path,
        )
        env = cc_common.get_environment_variables(
            action_name = OBJC_COMPILE_ACTION_NAME,
            feature_configuration = cc_feature_configuration,
            variables = compile_variables,
        )

        command_line = cc_common.get_memory_inefficient_command_line(
            action_name = OBJC_COMPILE_ACTION_NAME,
            feature_configuration = cc_feature_configuration,
            variables = compile_variables,
        )

        args = ctx.actions.args()
        args.add("-iquote" + private_hmap.path)
        args.add("-I" + public_hmap.path)
        args.add("-I.")
        args.add("-iquote" + private_hmap.path)
        args.add("-F", _VFS_ROOT)
        args.add_all(dep_cc_info.compilation_context.framework_includes, before_each = "-F")
        args.add("-ivfsoverlay", vfsoverlay_file.path)
        args.add("-fmodules")
        args.add_all(command_line)

        tool = cc_common.get_tool_for_action(feature_configuration = cc_feature_configuration, action_name = OBJC_COMPILE_ACTION_NAME)

        object_files.append(output)
        ctx.actions.run(
            executable = tool,
            arguments = [args],
            inputs = depset([file, private_hmap, public_hmap, vfsoverlay_file] + objc_hdrs, transitive = [cc_toolchain.all_files, dep_cc_info.compilation_context.headers]),
            outputs = [output],
            env = env,
        )

    archive = ctx.actions.declare_file("{name}/{bundle_name}.{bundle_extension}/{bundle_name}".format(
        name = ctx.label.name,
        bundle_name = ctx.label.name,
        bundle_extension = "framework",
    ))
    archiver_variables = cc_common.create_link_variables(
        cc_toolchain = cc_toolchain,
        feature_configuration = cc_feature_configuration,
        is_using_linker = False,
        output_file = archive.path,
    )
    command_line = cc_common.get_memory_inefficient_command_line(
        action_name = CPP_LINK_STATIC_LIBRARY_ACTION_NAME,
        feature_configuration = cc_feature_configuration,
        variables = archiver_variables,
    )
    env = cc_common.get_environment_variables(
        action_name = CPP_LINK_STATIC_LIBRARY_ACTION_NAME,
        feature_configuration = cc_feature_configuration,
        variables = archiver_variables,
    )
    execution_requirements_list = cc_common.get_execution_requirements(
        action_name = CPP_LINK_STATIC_LIBRARY_ACTION_NAME,
        feature_configuration = cc_feature_configuration,
    )
    execution_requirements = {req: "1" for req in execution_requirements_list}
    ctx.actions.run(
        executable = cc_common.get_tool_for_action(feature_configuration = cc_feature_configuration, action_name = CPP_LINK_STATIC_LIBRARY_ACTION_NAME),
        arguments = [ctx.actions.args().add_all(command_line).add_all(object_files)],
        inputs = depset(object_files, transitive = [cc_toolchain.all_files]),
        outputs = [archive],
        env = env,
        execution_requirements = execution_requirements,
    )

    copied_framework_files = []
    for (dir, files) in {"Headers": objc_hdrs, "PrivateHeaders": objc_private_hdrs, "Modules": [modulemap, swift_compilation.swiftmodule]}.items():
        for file in files:
            output = ctx.actions.declare_file("{name}/{bundle_name}.{bundle_extension}/{dir}/{file}".format(
                name = ctx.label.name,
                bundle_name = ctx.label.name,
                bundle_extension = "framework",
                file = file.basename,
                dir = dir,
            ))
            copied_framework_files.append(output)
            ctx.actions.symlink(
                output = output,
                target_file = file,
            )

    return [
        DefaultInfo(
            files = depset([archive] + copied_framework_files),
        ),
    ]

apple_library_2 = rule(
    implementation = _apple_library_2_impl,
    fragments = ["apple", "cpp", "objc"],
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "module_name": attr.string(mandatory = False),
        "deps": attr.label_list(
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
            doc = """\
The C++ toolchain from which linking flags and other tools needed by the Swift
toolchain (such as `clang`) will be retrieved.
""",
        ),
        "_swift_toolchain": attr.label(
            default = Label("@build_bazel_rules_swift_local_config//:toolchain"),
            providers = [[SwiftToolchainInfo]],
        ),
        "_headermap_builder": attr.label(
            executable = True,
            cfg = "host",
            default = Label(
                "//rules/hmap:hmaptool",
            ),
        ),
    },
)
