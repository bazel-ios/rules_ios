load("@bazel_skylib//lib:sets.bzl", "sets")
load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo", "SwiftToolchainInfo", "swift_common")
load("//rules:transition_support.bzl", "transition_support")
load("@build_bazel_rules_apple//apple/internal:apple_product_type.bzl", "apple_product_type")
load("@build_bazel_rules_apple//apple/internal:rule_support.bzl", "rule_support")
load("//rules:hmap.bzl", "hmap")
load(
    "@bazel_tools//tools/build_defs/cc:action_names.bzl",
    "CPP_LINK_STATIC_LIBRARY_ACTION_NAME",
    "OBJC_COMPILE_ACTION_NAME",
)

_VFS_ROOT = "/__com_github_bazel_ios_rules_ios/framework"

def _tool_attrs():
    return {
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
            doc = """\
The C++ toolchain from which linking flags and other tools needed by the Swift & Objective-C
toolchains (such as `clang`) will be retrieved.
""",
            providers = [[cc_common.CcToolchainInfo]],
        ),
        "_swift_toolchain": attr.label(
            default = Label("@build_bazel_rules_swift_local_config//:toolchain"),
            providers = [[SwiftToolchainInfo]],
            doc = """\
""",
        ),
        "_headermap_builder": attr.label(
            executable = True,
            cfg = "host",
            default = Label(
                "//rules/hmap:hmaptool",
            ),
            doc = """\
""",
        ),
    }

_DEFAULT_HDRS_EXTENSIONS = ["h", "hh", "hpp"]
_DEFAULT_SRCS_EXTENSIONS = _DEFAULT_HDRS_EXTENSIONS + ["m", "mm", "c", "cpp", "swift"]
_DEFAULT_DEPS_PROVIDERS = [
    [SwiftInfo],
    [CcInfo],
    [apple_common.Objc],  # TODO: to be removed, once it's unsupported in bazel upstream
]

def _library_attrs(srcs_files = _DEFAULT_SRCS_EXTENSIONS, headers_files = _DEFAULT_HDRS_EXTENSIONS, deps_providers = _DEFAULT_DEPS_PROVIDERS, platform_transition = True):
    if platform_transition:
        transition_attrs = {
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
            "_whitelist_function_transition": attr.label(
                default = "@build_bazel_rules_apple//tools/whitelists/function_transition_whitelist",
                doc = "Needed to allow this rule to have an incoming edge configuration transition.",
            ),
            "fail_on_apple_rule_transition_platform_mismatches": attr.bool(default = False),
        }
    else:
        transition_attrs = {}

    library_attrs = {
        "srcs": attr.label_list(allow_files = srcs_files),
        "private_headers": attr.label_list(allow_files = headers_files),
        "module_name": attr.string(mandatory = False),
        "deps": attr.label_list(
            providers = deps_providers,
        ),
    }
    return dicts.add(transition_attrs, library_attrs)

def _bundling_attrs(apple_product_type, bundle_id_mandatory = False, bundle_extension_default = None):
    return {
        "bundle_id": attr.string(
            mandatory = bundle_id_mandatory,
            doc = "The bundle identifier of the bundle. Currently unused.",
        ),
        "bundle_extension": attr.string(
            default = bundle_extension_default,
            doc = "The extension of the bundle.",
        ),
        "_product_type": attr.string(default = apple_product_type),
    }

def _fragments():
    return ["apple", "cpp", "objc"]

# _OVERRIDDEN_DESCRIPTORS = {
#     None: struct(),
# }

# def _rules_apple_rule_descriptor(platform_type, product_type):
#     if (platform_type, product_type) in _OVERRIDDEN_DESCRIPTORS:
#         return _OVERRIDDEN_DESCRIPTORS[(platform_type, product_type)]
#     return rule_support.rule_descriptor_no_ctx(
#         platform_type, product_type
#     )

def _apple_library_rule(implementation, is_library = True, bundle_platform = None, platform_transition = True, custom_attrs = {}):
    attr_list = [
        _tool_attrs(),
    ]

    if is_library:
        attr_list.append(_library_attrs(platform_transition = platform_transition))
    if bundle_platform:
        attr_list.append(_bundling_attrs(platform = bundle_platform))

    attr_list.append(custom_attrs)

    transition = transition_support.apple_rule_transition if platform_transition else None

    return rule(
        implementation = implementation,
        cfg = transition,
        fragments = _fragments(),
        attrs = dicts.add(*attr_list),
    )

def _uppercase_path_string(s):
    return s.path.upper()

def _write_modulemap(ctx, library_tools):
    if ctx.file.modulemap:
        return ctx.file.modulemap

    modulemap = library_tools.derived_files.modulemap()
    ctx.actions.declare_file(modulemap)
    return modulemap

def _extend_modulemap(ctx, library_tools, modulemap):
    if not modulemap:
        return None

    extended_modulemap = library_tools.derived_files.extended_modulemap()
    ctx.actions.run()
    return extended_modulemap

def _partition_srcs(name, srcs, private_headers = None, public_headers = None):
    private_headers = sets.make(private_headers) if private_headers else None
    public_headers = sets.make(public_headers) if public_headers else None

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
            fail("Unable to compile %s in %s" % (f, name))

    return struct(
        objc_sources = objc_sources,
        swift_sources = swift_sources,
        cpp_sources = cpp_sources,
        objc_non_exported_hdrs = objc_non_exported_hdrs,
        objc_private_hdrs = objc_private_hdrs,
        objc_hdrs = objc_hdrs,
    )

def _apple_library_2_impl(ctx):
    name = ctx.label
    module_name = ctx.attr.module_name or name.name

    srcs = _partition_srcs(srcs = ctx.files.srcs, name = name)

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

    ctx.actions.write(umbrella_header, "\n".join(["#import \"%s\"" % h.basename for h in srcs.objc_hdrs]))
    ctx.actions.write(modulemap, """framework module %s {
  umbrella header \"%s\"

  export *
  module * { export * }
}
""" % (module_name, umbrella_header.basename))

    srcs.objc_hdrs.append(umbrella_header)

    dep_cc_info = cc_common.merge_cc_infos(cc_infos = [dep[CcInfo] for dep in ctx.attr.deps if CcInfo in dep])

    virtual_header_files = [
        {
            "type": "file",
            "name": header.basename,
            "external-contents": header.path,
        }
        for header in srcs.objc_hdrs
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
        srcs = srcs.swift_sources,
        swift_toolchain = swift_toolchain,
        target_name = ctx.label.name,
        additional_inputs = [vfsoverlay_file, modulemap, umbrella_header] + srcs.objc_hdrs,
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
    srcs.objc_hdrs.append(swift_compilation.generated_header)
    object_files.extend(swift_compilation.object_files)

    hmap.make_hmap(
        actions = ctx.actions,
        headermap_builder = ctx.executable._headermap_builder,
        output = private_hmap,
        namespace = module_name,
        hdrs_lists = (srcs.objc_hdrs, srcs.objc_private_hdrs, srcs.objc_non_exported_hdrs),
    )

    hmap.make_hmap(
        actions = ctx.actions,
        headermap_builder = ctx.executable._headermap_builder,
        output = public_hmap,
        namespace = module_name,
        hdrs_lists = (srcs.objc_hdrs,),
    )

    for file in srcs.objc_sources:
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
            inputs = depset([file, private_hmap, public_hmap, vfsoverlay_file] + srcs.objc_hdrs, transitive = [cc_toolchain.all_files, dep_cc_info.compilation_context.headers]),
            outputs = [output],
            env = env,
        )

    archive = ctx.actions.declare_file("{name}/{bundle_name}.{bundle_extension}/{bundle_name}".format(
        name = ctx.label.name,
        bundle_name = module_name,
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

    copied_framework_files = {}
    for (dir, files) in {"Headers": srcs.objc_hdrs, "PrivateHeaders": srcs.objc_private_hdrs, "Modules": [modulemap, swift_compilation.swiftmodule]}.items():
        for file in files:
            output = ctx.actions.declare_file("{name}/{bundle_name}.{bundle_extension}/{dir}/{file}".format(
                name = ctx.label.name,
                bundle_name = ctx.label.name,
                bundle_extension = "framework",
                file = file.basename,
                dir = dir,
            ))
            copied_framework_files[file] = output
            ctx.actions.symlink(
                output = output,
                target_file = file,
            )

    return [
        DefaultInfo(
            files = depset([archive]),
        ),
    ]

apple_library_2 = _apple_library_rule(implementation = _apple_library_2_impl)
