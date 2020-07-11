"""
Rules to create a mixed-language apple library.
"""

load("@bazel_skylib//lib:sets.bzl", "sets")
load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo", "SwiftToolchainInfo", "SwiftUsageInfo", "swift_common")
load("@build_bazel_rules_swift//swift/internal:feature_names.bzl", "SWIFT_FEATURE_INDEX_WHILE_BUILDING")
load("//rules:transition_support.bzl", "transition_support")
load("@build_bazel_rules_apple//apple/internal:apple_product_type.bzl", "apple_product_type")
load("@build_bazel_rules_apple//apple/internal:rule_support.bzl", "rule_support")
load(
    "@build_bazel_rules_apple//apple/internal:resources.bzl",
    "resources",
)
load("@build_bazel_rules_apple//apple:providers.bzl", "AppleResourceInfo")
load("//rules:hmap.bzl", "hmap")
load(
    "@bazel_tools//tools/build_defs/cc:action_names.bzl",
    "CPP_COMPILE_ACTION_NAME",
    "CPP_LINK_STATIC_LIBRARY_ACTION_NAME",
    "C_COMPILE_ACTION_NAME",
    "OBJCPP_COMPILE_ACTION_NAME",
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
        "linkopts": attr.string_list(mandatory = False),
        "objc_copts": attr.string_list(mandatory = False),
        "sdk_frameworks": attr.string_list(mandatory = False),
        "namespace": attr.string(mandatory = False),
        "pch": attr.label(allow_single_file = ["pch"], mandatory = False, default = Label("@build_bazel_rules_ios//rules/library:common.pch")),
        "data": attr.label_list(allow_files = True, mandatory = False),
        "deps": attr.label_list(
            providers = deps_providers,
        ),
        "private_deps": attr.label_list(
            doc = """\
A list of targets that are implementation-only dependencies of the target being
built. Libraries/linker flags from these dependencies will be propagated to
dependent for linking, but artifacts/flags required for compilation (such as
.swiftmodule files, C headers, and search paths) will not be propagated.
""",
            providers = [
                [CcInfo],
                [SwiftInfo],
                [apple_common.Objc],
            ],
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
    objcpp_sources = []
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
        elif extension in ("m", "c"):
            objc_sources.append(f)
        elif extension in ("mm"):
            objcpp_sources.append(f)
        elif extension in ("swift",):
            swift_sources.append(f)
        elif extension in ("cc", "cpp"):
            cpp_sources.append(f)
        else:
            fail("Unable to compile %s in %s" % (f, name))

    return struct(
        objc_sources = objc_sources,
        objcpp_sources = objcpp_sources,
        swift_sources = swift_sources,
        cpp_sources = cpp_sources,
        objc_non_exported_hdrs = objc_non_exported_hdrs,
        objc_private_hdrs = objc_private_hdrs,
        objc_hdrs = objc_hdrs,
    )

def _cc_compile(srcs, prebuild, output_template, dep_cc_info, copts, actions, cc_toolchain, cc_feature_configuration):
    object_files = []
    for file in srcs.objc_sources:
        output = actions.declare_file(output_template.format(type = "objc_arc", filename = file.basename + ".o"))
        compile_variables = cc_common.create_compile_variables(
            cc_toolchain = cc_toolchain,
            feature_configuration = cc_feature_configuration,
            source_file = file.path,
            output_file = output.path,
            user_compile_flags = copts.objc,
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

        inputs = [file, prebuild.private_hmap, prebuild.public_hmap] + srcs.objc_hdrs + srcs.objc_non_exported_hdrs + srcs.objc_private_hdrs

        args = actions.args()
        args.add("-fobjc-arc")
        args.add(prebuild.private_hmap, format = "-iquote%s")
        args.add(prebuild.public_hmap, format = "-I%s")
        args.add("-I.")
        args.add(prebuild.private_hmap, format = "-iquote%s")
        args.add(_VFS_ROOT, format = "-F%s")
        args.add_all(dep_cc_info.compilation_context.framework_includes, before_each = "-F")

        outputs = [output]

        if SWIFT_FEATURE_INDEX_WHILE_BUILDING and False:
            indexstore = actions.declare_directory(output_template.format(type = "index_store", filename = file.basename + ".indexstore"))
            args.add("-index-store-path", indexstore.path)
            outputs.append(indexstore)

        if prebuild.vfsoverlay_file:
            args.add(prebuild.vfsoverlay_file, format = "-ivfsoverlay%s")
            inputs.append(prebuild.vfsoverlay_file)
        if prebuild.modulemap:
            args.add(prebuild.modulemap, format = "-fmodule-map-file=%s")
            inputs.append(prebuild.modulemap)
        if prebuild.pch:
            args.add("-include", prebuild.pch)
            inputs.append(prebuild.pch)
        args.add("-fmodules")
        args.add_all(command_line)

        tool = cc_common.get_tool_for_action(feature_configuration = cc_feature_configuration, action_name = OBJC_COMPILE_ACTION_NAME)

        object_files.append(output)
        actions.run(
            executable = tool,
            arguments = [args],
            inputs = depset(inputs, transitive = [cc_toolchain.all_files, dep_cc_info.compilation_context.headers]),
            outputs = outputs,
            env = env,
            mnemonic = "ObjcCompile",
        )
    return object_files

def _link(object_files, archive, actions, cc_toolchain, cc_feature_configuration):
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
    actions.run(
        executable = cc_common.get_tool_for_action(feature_configuration = cc_feature_configuration, action_name = CPP_LINK_STATIC_LIBRARY_ACTION_NAME),
        arguments = [actions.args().add_all(command_line).add_all(object_files)],
        inputs = depset(object_files, transitive = [cc_toolchain.all_files]),
        outputs = [archive],
        env = env,
        execution_requirements = execution_requirements,
    )

def _library_data(label, swift_module_name, files, deps):
    providers = []

    bucketize_args = {}
    collect_args = {}

    if swift_module_name:
        bucketize_args["swift_module"] = swift_module_name
    collect_args["res_attrs"] = ["data"]
    owner = str(label)

    # Collect all resource files related to this target.
    if files:
        providers.append(
            resources.bucketize(files, owner = owner, **bucketize_args),
        )

    # Get the providers from dependencies.
    providers.extend([
        x[AppleResourceInfo]
        for x in deps
        if AppleResourceInfo in x
    ])

    if providers:
        # If any providers were collected, merge them.
        return [resources.merge_providers(providers, default_owner = owner)]
    return []

def _apple_library_2_impl(ctx):
    name = ctx.label
    module_name = ctx.attr.module_name or name.name
    namespace_is_module_name = (not ctx.attr.namespace) or (ctx.attr.namespace == module_name) and "-" not in module_name
    bundle_extension = getattr(ctx.attr, "bundle_extension", "framework")
    providers = []

    srcs = _partition_srcs(srcs = ctx.files.srcs, name = name)

    output_template = "_objs/%s/{type}/{filename}" % (name.name)

    cc_toolchain = ctx.attr._cc_toolchain[cc_common.CcToolchainInfo]

    cc_feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    object_files = []

    private_hmap = ctx.actions.declare_file(output_template.format(type = "hmap", filename = "private.hmap"))
    public_hmap = ctx.actions.declare_file(output_template.format(type = "hmap", filename = "public.hmap"))
    modulemap = None
    vfsoverlay_file = None
    umbrella_header = None
    if namespace_is_module_name:
        modulemap = ctx.actions.declare_file(output_template.format(type = "modulemap", filename = module_name + ".modulemap"))
        umbrella_header = ctx.actions.declare_file(output_template.format(type = "umbrella_header", filename = module_name + "-umbrella.h"))
        vfsoverlay_file = ctx.actions.declare_file(output_template.format(type = "vfsoverlay", filename = module_name + ".vfsoverlay.yaml"))

        ctx.actions.write(umbrella_header, """\
#ifdef __OBJC__
#    import <Foundation/Foundation.h>
#    if __has_include(<UIKit/UIKit.h>)
#        import <UIKit/UIKit.h>
#    endif
#else
#    ifndef FOUNDATION_EXPORT
#        if defined(__cplusplus)
#            define FOUNDATION_EXPORT extern "C"
#        else
#            define FOUNDATION_EXPORT extern
#        endif
#    endif
#endif

""" +
                                           "".join(["#import \"%s\"\n" % h.basename for h in srcs.objc_hdrs]))
        ctx.actions.write(modulemap, """\
framework module %s {
    umbrella header \"%s\"

    export *
    module * { export * }
}
""" % (module_name, umbrella_header.basename))

        srcs.objc_hdrs.append(umbrella_header)

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
                        {"type": "directory", "name": "{}.framework".format(ctx.attr.namespace or module_name), "contents": [
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

    swift_compilation = None
    swift_toolchain = None
    if srcs.swift_sources:
        swift_toolchain = ctx.attr._swift_toolchain[SwiftToolchainInfo]
        swift_features = swift_common.configure_features(ctx = ctx, swift_toolchain = swift_toolchain, requested_features = ctx.features, unsupported_features = ctx.disabled_features)
        providers.append(SwiftUsageInfo(toolchain = swift_toolchain))
        parse_as_library = ["-parse-as-library"]
        for src in srcs.swift_sources:
            if src.basename == "main.swift":
                parse_as_library = []
                break
        copts = parse_as_library
        if vfsoverlay_file:
            copts.extend((
                "-Xfrontend",
                "-vfsoverlay{}".format(vfsoverlay_file.path),
                "-F" + _VFS_ROOT,
            ))
        additional_inputs = [] + srcs.objc_hdrs
        if vfsoverlay_file:
            additional_inputs.append(vfsoverlay_file)
        if modulemap:
            copts.append("-import-underlying-module")
            additional_inputs.append(modulemap)
        swift_compilation = swift_common.compile(
            actions = ctx.actions,
            feature_configuration = swift_features,
            module_name = module_name,
            srcs = srcs.swift_sources,
            swift_toolchain = swift_toolchain,
            target_name = ctx.label.name,
            additional_inputs = additional_inputs,
            bin_dir = None,
            copts = copts + [
                "-Xcc",
                "-iquote{}".format(private_hmap.path),
                "-Xcc",
                "-I{}".format(public_hmap.path),
                "-Xcc",
                "-I.",
                "-Xcc",
                "-D__SWIFTC__",
                "-Xfrontend",
                "-no-clang-module-breadcrumbs",
            ],
            defines = [],
            deps = ctx.attr.deps + ctx.attr.private_deps,
            generated_header_name = "{}-Swift.h".format(module_name),
            genfiles_dir = None,
        )
    if swift_compilation:
        srcs.objc_hdrs.append(swift_compilation.generated_header)
        object_files.extend(swift_compilation.object_files)

    if swift_compilation and modulemap:
        extended_modulemap = ctx.actions.declare_file(module_name + ".extended.modulemap", sibling = modulemap)
        ctx.actions.run_shell(
            inputs = [modulemap],
            outputs = [extended_modulemap],
            mnemonic = "ExtendModulemap",
            progress_message = "Extending %s" % modulemap.basename,
            command = "echo \"$1\" | cat <(perl -0 -pe 's/\\A(framework )?/framework /m' $2) - > $3",
            arguments = [ctx.actions.args()
                .add("""
module {module_name}.Swift {{
    header "{swift_umbrella_header}"
    requires objc
}}""".format(
                module_name = module_name,
                swift_umbrella_header = swift_compilation.generated_header.basename,
            ))
                .add(modulemap)
                .add(extended_modulemap)],
        )
        modulemap = extended_modulemap

    hmap.make_hmap(
        actions = ctx.actions,
        headermap_builder = ctx.executable._headermap_builder,
        output = private_hmap,
        namespace = ctx.attr.namespace or module_name,
        hdrs_lists = (srcs.objc_hdrs, srcs.objc_private_hdrs, srcs.objc_non_exported_hdrs),
    )

    hmap.make_hmap(
        actions = ctx.actions,
        headermap_builder = ctx.executable._headermap_builder,
        output = public_hmap,
        namespace = ctx.attr.namespace or module_name,
        hdrs_lists = (srcs.objc_hdrs,),
    )

    dep_cc_info = cc_common.merge_cc_infos(cc_infos = [dep[CcInfo] for dep in ctx.attr.deps + ctx.attr.private_deps if CcInfo in dep])
    object_files += _cc_compile(srcs = srcs, prebuild = struct(private_hmap = private_hmap, public_hmap = public_hmap, vfsoverlay_file = vfsoverlay_file, modulemap = modulemap, pch = ctx.file.pch), output_template = output_template, dep_cc_info = dep_cc_info, copts = struct(objc = ctx.attr.objc_copts), actions = ctx.actions, cc_toolchain = cc_toolchain, cc_feature_configuration = cc_feature_configuration)

    archive = []
    if object_files:
        archive = [ctx.actions.declare_file("{name}/{bundle_name}.{bundle_extension}/{bundle_name}".format(
            name = ctx.label.name,
            bundle_name = module_name,
            bundle_extension = bundle_extension,
        ))]
        _link(object_files = object_files, archive = archive[0], actions = ctx.actions, cc_toolchain = cc_toolchain, cc_feature_configuration = cc_feature_configuration)

    copied_framework_paths = {}
    for (dir, files) in {"Headers": srcs.objc_hdrs, "PrivateHeaders": srcs.objc_private_hdrs}.items():
        for file in files:
            copied_framework_paths[file] = "{name}/{bundle_name}.{bundle_extension}/{dir}/{file}".format(
                name = ctx.label.name,
                bundle_name = module_name,
                bundle_extension = bundle_extension,
                file = file.basename,
                dir = dir,
            )
    if swift_compilation:
        copied_framework_paths[swift_compilation.swiftmodule] = "{name}/{bundle_name}.{bundle_extension}/{dir}/{file}".format(
            name = ctx.label.name,
            bundle_name = module_name,
            bundle_extension = bundle_extension,
            file = "x86_64.swiftmodule",
            dir = "Modules/" + swift_compilation.swiftmodule.basename,
        )
        copied_framework_paths[swift_compilation.swiftdoc] = "{name}/{bundle_name}.{bundle_extension}/{dir}/{file}".format(
            name = ctx.label.name,
            bundle_name = module_name,
            bundle_extension = bundle_extension,
            file = "x86_64.swiftdoc",
            dir = "Modules/" + swift_compilation.swiftmodule.basename,
        )

    if modulemap:
        copied_framework_paths[modulemap] = "{name}/{bundle_name}.{bundle_extension}/{dir}/{file}".format(
            name = ctx.label.name,
            bundle_name = module_name,
            bundle_extension = bundle_extension,
            file = "module.modulemap",
            dir = "Modules",
        )
    copied_framework_files = {}
    for (original, fw_path) in copied_framework_paths.items():
        if namespace_is_module_name:
            fw = ctx.actions.declare_file(fw_path)
            ctx.actions.symlink(
                output = fw,
                target_file = original,
            )
            copied_framework_files[original] = fw
        else:
            copied_framework_files[original] = original

    # gather swift info fields
    swift_info_fields = {
        "swift_infos": [dep[SwiftInfo] for dep in ctx.attr.deps if SwiftInfo in dep],
    }

    if swift_compilation:
        # only add a swift module to the SwiftInfo if we've actually got a swiftmodule

        # need to include the swiftmodule here, even though it will be found through the framework search path,
        # since swift_library needs to know that the swiftdoc is an input to the compile action
        swift_module = swift_common.create_swift_module(
            swiftdoc = swift_compilation.swiftdoc,
            swiftmodule = copied_framework_files[swift_compilation.swiftmodule] if namespace_is_module_name else swift_compilation.swiftmodule,
            swiftinterface = swift_compilation.swiftinterface,
        )

        swift_info_fields["modules"] = [
            # only add the swift module, the objc modulemap is already listed as a header,
            # and it will be discovered via the framework search path
            swift_common.create_module(name = module_name, swift = swift_module),
        ]

    linkopts = list(ctx.attr.linkopts)
    link_inputs = []
    if swift_compilation:
        linkopts += swift_compilation.linker_flags
        link_inputs += swift_compilation.linker_inputs

    objc_provider = apple_common.new_objc_provider(
        # when migrating to CcInfo, only propogate linking context of private deps
        providers = [dep[apple_common.Objc] for dep in ctx.attr.deps + ctx.attr.private_deps if apple_common.Objc in dep],
        framework_search_paths = depset([_VFS_ROOT + "{name}/{bundle_name}.{bundle_extension}".format(name = ctx.label.name, bundle_name = module_name, bundle_extension = bundle_extension)]),
        header = depset([copied_framework_files[f] for f in srcs.objc_hdrs]),
        module_map = depset([copied_framework_files[modulemap]] if modulemap else []),
        umbrella_header = depset([copied_framework_files[umbrella_header]] if modulemap else []),
        uses_swift = swift_compilation != None,
        link_inputs = depset(link_inputs),
        linkopt = depset(linkopts),
        static_framework_file = depset(archive),
        sdk_framework = depset(ctx.attr.sdk_frameworks),
    )
    cc_info_provider = CcInfo(compilation_context = objc_provider.compilation_context)
    return providers + [
        DefaultInfo(
            files = depset(archive + copied_framework_files.values()),
            runfiles = ctx.runfiles(
                collect_data = True,
                collect_default = True,
                files = ctx.files.data,
            ),
        ),
        objc_provider,
        cc_info_provider,
        swift_common.create_swift_info(**swift_info_fields),
    ] + _library_data(label = name, swift_module_name = module_name if swift_toolchain else None, files = ctx.files.data, deps = ctx.attr.deps + ctx.attr.private_deps + ctx.attr.data)

apple_library_2 = _apple_library_rule(implementation = _apple_library_2_impl)

tools = struct(
    modulemap = None,
    hmap = None,
    vfsoverlay = None,
    partition_srcs = None,
)
