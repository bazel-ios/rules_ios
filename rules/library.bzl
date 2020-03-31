load("@rules_cc//cc:defs.bzl", "cc_library", "objc_import", "objc_library")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:sets.bzl", "sets")
load("@build_bazel_rules_apple//apple:apple.bzl", "apple_dynamic_framework_import", "apple_static_framework_import")
load("@build_bazel_rules_apple//apple:resources.bzl", "apple_resource_bundle")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("//rules:hmap.bzl", "headermap")
load("//rules:substitute_build_settings.bzl", "substitute_build_settings")
load("//rules/library:resources.bzl", "wrap_resources_in_filegroup")
load("//rules/library:xcconfig.bzl", "settings_from_xcconfig")

PrivateHeaders = provider(
    doc = "Propagates private headers, so they can be accessed if necessary",
    fields = {
        "headers": "Private headers",
    },
)

_MANUAL = ["manual"]

def _private_headers_impl(ctx):
    return [
        PrivateHeaders(
            headers = depset(direct = ctx.files.headers),
        ),
        apple_common.new_objc_provider(),
    ]

_private_headers = rule(
    implementation = _private_headers_impl,
    attrs = {
        "headers": attr.label_list(mandatory = True, allow_files = [".h", ".hh", ".hpp"]),
    },
)

def _write_file_impl(ctx):
    ctx.actions.write(
        output = ctx.outputs.destination,
        content = ctx.attr.content,
    )

write_file = rule(
    implementation = _write_file_impl,
    attrs = {
        "content": attr.string(),
        "destination": attr.output(),
    },
    doc = "Writes out a file verbatim",
)

def _extend_modulemap_impl(ctx):
    args = ctx.actions.args()
    args.add("""
module {module_name}.Swift {{
    header "{swift_umbrella_header}"
    requires objc
}}""".format(
        module_name = ctx.attr.module_name,
        swift_umbrella_header = ctx.attr.swift_header,
    ))
    args.add(ctx.file.source)
    args.add(ctx.outputs.destination)
    ctx.actions.run_shell(
        inputs = [ctx.file.source],
        outputs = [ctx.outputs.destination],
        mnemonic = "ExtendModulemap",
        progress_message = "Extending %s" % ctx.file.source.basename,
        command = "echo \"$1\" | cat <(echo -n 'framework ') $2 - > $3",
        arguments = [args],
    )

extend_modulemap = rule(
    implementation = _extend_modulemap_impl,
    attrs = {
        "source": attr.label(
            doc = "",
            allow_single_file = True,
        ),
        "destination": attr.output(),
        "module_name": attr.string(
            mandatory = True,
        ),
        "swift_header": attr.string(
            doc = "",
        ),
    },
    doc = "Extends a modulemap with a Swift submodule",
)

def write_modulemap(name, library_tools, umbrella_header = None, public_headers = [], private_headers = [], module_name = None, framework = False, **kwargs):
    basename = "{}.modulemap".format(name)
    destination = paths.join(name + "-modulemap", basename)
    if not module_name:
        module_name = name
    content = """\
module {module_name} {{
    umbrella header "{umbrella_header}"

    export *
    module * {{ export * }}
}}
""".format(
        module_name = module_name,
        umbrella_header = umbrella_header,
    )
    if framework:
        content = "framework " + content

    write_file(
        name = basename + "~",
        destination = destination,
        content = content,
        tags = _MANUAL,
    )
    return destination

def write_umbrella_header(name, library_tools, public_headers = [], private_headers = [], module_name = None, **kwargs):
    basename = "{name}-umbrella.h".format(name = name)
    destination = paths.join(name + "-modulemap", basename)
    if not module_name:
        module_name = name
    content = """\
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

"""

    for header in public_headers:
        content += "#import \"{header}\"\n".format(header = paths.basename(header))

    content += """
FOUNDATION_EXPORT double {module_name}VersionNumber;
FOUNDATION_EXPORT const unsigned char {module_name}VersionString[];
""".format(
        module_name = module_name,
    )

    write_file(
        name = basename + "~",
        destination = destination,
        content = content,
        tags = _MANUAL,
    )
    return destination

def generate_resource_bundles(name, library_tools, module_name, resource_bundles, **kwargs):
    bundle_target_names = []
    for bundle_name in resource_bundles:
        target_name = "%s-%s" % (name, bundle_name)
        substitute_build_settings(
            name = name + ".info.plist",
            source = "@build_bazel_rules_ios//rules/library:resource_bundle.plist",
            variables = {
                "PRODUCT_BUNDLE_IDENTIFIER": "com.cocoapods.%s" % bundle_name,
                "PRODUCT_NAME": bundle_name,
            },
            tags = _MANUAL,
        )
        apple_resource_bundle(
            name = target_name,
            bundle_name = bundle_name,
            resources = [
                library_tools["wrap_resources_in_filegroup"](name = target_name + "_resources", srcs = resource_bundles[bundle_name]),
            ],
            infoplists = [name + ".info.plist"],
            tags = _MANUAL,
        )
        bundle_target_names.append(target_name)
    return bundle_target_names

def _error_on_default_xcconfig(name, library_tools, default_xcconfig_name, **kwargs):
    fail("{name} specifies a default xcconfig ({default_xcconfig_name}). You must override fetch_default_xcconfig to use this feature.".format(
        name = name,
        default_xcconfig_name = default_xcconfig_name,
    ))

_DefaultLibraryTools = {
    "modulemap_generator": write_modulemap,
    "umbrella_header_generator": write_umbrella_header,
    "resource_bundle_generator": generate_resource_bundles,
    "wrap_resources_in_filegroup": wrap_resources_in_filegroup,
    "fetch_default_xcconfig": _error_on_default_xcconfig,
}

def _prepend_copts(copts_struct, objc_copts, cc_copts, swift_copts, linkopts, ibtool_copts, momc_copts, mapc_copts):
    objc_copts = copts_struct.objc_copts + objc_copts
    cc_copts = copts_struct.cc_copts + cc_copts
    swift_copts = copts_struct.swift_copts + swift_copts
    linkopts = copts_struct.linkopts + linkopts
    ibtool_copts = copts_struct.ibtool_copts + ibtool_copts
    momc_copts = copts_struct.momc_copts + momc_copts
    mapc_copts = copts_struct.mapc_copts + mapc_copts

def _uppercase_string(s):
    return s.upper()

def apple_library(name, library_tools = {}, export_private_headers = True, namespace_is_module_name = True, default_xcconfig_name = None, xcconfig = {}, **kwargs):
    """Create libraries for native source code on Apple platforms.

    Automatically handles mixed-source libraries and comes with
    reasonable defaults that mimic Xcode's behavior.

    Args:
        name: The base name for all of the underlying targets.
        library_tools:  An optional dictionary containing overrides for
                        default behaviors.
        export_private_headers: Whether private headers should be exported via
                                a `PrivateHeaders` provider.
        namespace_is_module_name: Whether the module name should be used as the
                                  namespace for header imports, instead of the target name.
        default_xcconfig_name: The name of a default xcconfig to be applied to this target.
        xcconfig: A dictionary of Xcode build settings to be applied to this target in the
                  form of different `copt` attributes.
    """
    library_tools = dict(_DefaultLibraryTools, **library_tools)
    swift_sources = []
    objc_sources = []
    objc_non_arc_sources = []
    cpp_sources = []
    public_headers = kwargs.pop("public_headers", [])
    private_headers = kwargs.pop("private_headers", [])
    objc_hdrs = [f for f in public_headers if f.endswith((".h", ".hh"))]
    objc_non_exported_hdrs = []
    objc_private_hdrs = [f for f in private_headers if f.endswith((".h", ".hh"))]
    if public_headers:
        public_headers = sets.make(public_headers)
    if private_headers:
        private_headers = sets.make(private_headers)
    for f in sorted(kwargs.pop("non_arc_srcs", []), key = _uppercase_string):
        if f.endswith((".m", ".mm")):
            objc_non_arc_sources.append(f)
        else:
            kwargs["srcs"] = kwargs.pop("srcs", []) + [f]
    for f in sorted(kwargs.pop("srcs", []), key = _uppercase_string):
        if f.endswith((".h", ".hh")):
            if (private_headers and sets.contains(private_headers, f)) or \
               (public_headers and sets.contains(public_headers, f)):
                pass
            elif public_headers and private_headers:
                objc_non_exported_hdrs.append(f)
            elif public_headers:
                objc_private_hdrs.append(f)
            else:
                objc_hdrs.append(f)
        elif f.endswith((".m", ".mm", ".c")):
            objc_sources.append(f)
        elif f.endswith((".swift")):
            swift_sources.append(f)
        elif f.endswith((".cc", ".cpp")):
            cpp_sources.append(f)
        else:
            fail("Unable to compile %s in apple_framework %s" % (f, name))

    module_name = kwargs.pop("module_name", name)
    namespace = module_name if namespace_is_module_name else name
    module_map = kwargs.pop("module_map", None)
    cc_copts = kwargs.pop("cc_copts", [])
    swift_copts = kwargs.pop("swift_copts", [])
    ibtool_copts = kwargs.pop("ibtool_copts", [])
    momc_copts = kwargs.pop("momc_copts", [])
    mapc_copts = kwargs.pop("mapc_copts", [])
    linkopts = kwargs.pop("linkopts", [])
    objc_copts = kwargs.pop("objc_copts", [])
    other_inputs = kwargs.pop("other_inputs", [])
    sdk_dylibs = kwargs.pop("sdk_dylibs", [])
    sdk_frameworks = kwargs.pop("sdk_frameworks", [])
    weak_sdk_frameworks = kwargs.pop("weak_sdk_frameworks", [])
    sdk_includes = kwargs.pop("sdk_includes", [])
    pch = kwargs.pop("pch", "@build_bazel_rules_ios//rules/library:common.pch")
    deps = kwargs.pop("deps", [])
    data = kwargs.pop("data", [])
    tags = kwargs.pop("tags", [])
    tags_manual = tags if "manual" in tags else tags + _MANUAL
    internal_deps = []
    lib_names = []

    if default_xcconfig_name:
        for (setting, value) in library_tools["fetch_default_xcconfig"](name, library_tools, default_xcconfig_name, **kwargs).items():
            if not setting in xcconfig:
                xcconfig[setting] = value
    xcconfig_settings = settings_from_xcconfig(xcconfig)
    _prepend_copts(xcconfig_settings, objc_copts, cc_copts, swift_copts, linkopts, ibtool_copts, momc_copts, mapc_copts)

    for (k, v) in {"momc_copts": momc_copts, "mapc_copts": mapc_copts, "ibtool_copts": ibtool_copts}.items():
        if v:
            fail("Specifying {attr} for {name} is not yet supported. Given: {opts}".format(
                attr = k,
                name = name,
                opts = repr(v),
            ))

    if linkopts:
        linkopts_name = "%s_linkopts" % (name)

        # https://docs.bazel.build/versions/master/be/c-cpp.html#cc_library
        cc_library(
            name = linkopts_name,
            linkopts = linkopts,
        )
        internal_deps += [linkopts_name]

    for vendored_static_framework in kwargs.pop("vendored_static_frameworks", []):
        import_name = "%s-%s-import" % (name, paths.basename(vendored_static_framework))
        apple_static_framework_import(
            name = import_name,
            framework_imports = native.glob(["%s/**/*" % vendored_static_framework]),
            tags = _MANUAL,
        )
        deps += [import_name]
    for vendored_dynamic_framework in kwargs.pop("vendored_dynamic_frameworks", []):
        import_name = "%s-%s-import" % (name, paths.basename(vendored_dynamic_framework))
        apple_dynamic_framework_import(
            name = import_name,
            framework_imports = native.glob(["%s/**/*" % vendored_dynamic_framework]),
            deps = [],
            tags = _MANUAL,
        )
        deps += [import_name]
    for vendored_static_library in kwargs.pop("vendored_static_libraries", []):
        import_name = "%s-%s-library-import" % (name, paths.basename(vendored_static_library))
        objc_import(
            name = import_name,
            archives = [vendored_static_library],
            tags = _MANUAL,
        )
        deps += [import_name]
    for vendored_dynamic_library in kwargs.pop("vendored_dynamic_libraries", []):
        fail("no import for %s" % vendored_dynamic_library)

    resource_bundles = library_tools["resource_bundle_generator"](
        name = name,
        library_tools = library_tools,
        resource_bundles = kwargs.pop("resource_bundles", {}),
        module_name = module_name,
        **kwargs
    )
    deps += resource_bundles

    ## BEGIN HMAP
    public_hmap_name = name + "_public_hmap"
    public_hdrs_filegroup = name + "_public_hdrs"
    native.filegroup(
        name = public_hdrs_filegroup,
        srcs = objc_hdrs,
        tags = _MANUAL,
    )

    # Public hmaps are for vendored static libs to export their header only.
    # Other dependencies' headermaps will be generated by li_ios_framework
    # rules.
    headermap(
        name = public_hmap_name,
        namespace = namespace,
        hdrs = [public_hdrs_filegroup],
        hdr_providers = deps,
        flatten_headers = True,
        tags = _MANUAL,
    )
    internal_deps.append(public_hmap_name)

    if swift_sources:
        generated_swift_header_name = module_name + "-Swift.h"
        generated_swift_headers_filegroup = name + "_swift_hdrs"
        native.filegroup(
            name = generated_swift_headers_filegroup,
            srcs = [generated_swift_header_name],
            tags = _MANUAL,
        )

        # Add generated swift header to header maps for double quote imports
        swift_doublequote_hmap_name = name + "_swift_doublequote_hmap"
        headermap(
            name = swift_doublequote_hmap_name,
            namespace = namespace,
            hdrs = [generated_swift_headers_filegroup],
            hdr_providers = deps,
            flatten_headers = True,
            tags = _MANUAL,
        )
        internal_deps.append(swift_doublequote_hmap_name)

    private_hmap_name = name + "_private_hmap"
    private_angled_hmap_name = name + "_private_angled_hmap"
    private_hdrs_filegroup = name + "_private_hdrs"
    private_angled_hdrs_filegroup = name + "_private_angled_hdrs"
    native.filegroup(
        name = private_hdrs_filegroup,
        srcs = objc_non_exported_hdrs + objc_private_hdrs + objc_hdrs,
        tags = _MANUAL,
    )
    native.filegroup(
        name = private_angled_hdrs_filegroup,
        srcs = objc_non_exported_hdrs + objc_private_hdrs,
        tags = _MANUAL,
    )

    headermap(
        name = private_hmap_name,
        namespace = namespace,
        hdrs = [private_hdrs_filegroup],
        flatten_headers = False,
        tags = _MANUAL,
    )
    internal_deps.append(private_hmap_name)
    headermap(
        name = private_angled_hmap_name,
        namespace = namespace,
        hdrs = [private_angled_hdrs_filegroup],
        flatten_headers = True,
        tags = _MANUAL,
    )
    internal_deps.append(private_angled_hmap_name)
    ## END HMAP

    # vfs_name = name + '_vfs'
    # vfs_overlay(name = vfs_name, deps = deps)
    # internal_deps.append(vfs_name)

    headermap_copts = []
    headermap_copts.append("-I\"$(execpath :%s)\"" % private_hmap_name)
    headermap_copts.append("-I\"$(execpath :%s)\"" % public_hmap_name)
    headermap_copts.append("-I\"$(execpath :%s)\"" % private_angled_hmap_name)
    if swift_sources:
        # headermap_copts.append("-iquote\"$(execpath :%s)\"" % swift_doublequote_hmap_name)
        headermap_copts.append("-I\"$(execpath :%s)\"" % swift_doublequote_hmap_name)
    headermap_copts.append("-I.")
    headermap_copts.append("-iquote\"$(execpath :%s)\"" % private_hmap_name)

    objc_copts += headermap_copts + [
        "-fmodules",
        "-fmodule-name=%s" % module_name,
        "-gmodules",
    ]

    swift_copts += [j for i in ([["-Xcc", copt] for copt in headermap_copts]) for j in i] + [
        "-Xcc",
        "-D__SWIFTC__",
    ]

    swift_version = kwargs.pop("swift_version", None)
    if swift_version:
        if swift_version.endswith(".0"):
            swift_version = swift_version[:-2]
        if swift_version.endswith(".0"):
            swift_version = swift_version[:-2]
        swift_copts += ["-swift-version", swift_version]

    cc_copts += headermap_copts

    objc_libname = "%s_objc" % name
    swift_libname = "%s_swift" % name
    cpp_libname = "%s_cpp" % name

    # TODO: remove framework if set
    if namespace_is_module_name and not module_map and \
       (objc_hdrs or objc_private_hdrs or swift_sources or objc_sources or cpp_sources):
        umbrella_header = library_tools["umbrella_header_generator"](
            name = name,
            library_tools = library_tools,
            public_headers = objc_hdrs,
            private_headers = objc_private_hdrs,
            module_name = module_name,
            **kwargs
        )
        if umbrella_header:
            objc_hdrs += [umbrella_header]
        module_map = library_tools["modulemap_generator"](
            name = name,
            library_tools = library_tools,
            umbrella_header = paths.basename(umbrella_header),
            public_headers = objc_hdrs,
            private_headers = objc_private_hdrs,
            module_name = module_name,
            framework = False if swift_sources else True,
            **kwargs
        )

    if swift_sources:
        if module_map:
            swift_copts += [
                "-Xcc",
                "-fmodule-map-file=" + "$(execpath " + module_map + ")",
                "-import-underlying-module",
            ]
        swiftc_inputs = other_inputs + objc_hdrs
        if module_map:
            swiftc_inputs.append(module_map)
        generated_header_name = module_name + "-Swift.h"
        swift_library(
            name = swift_libname,
            module_name = module_name,
            generated_header_name = generated_header_name,
            srcs = swift_sources,
            copts = swift_copts,
            deps = deps + internal_deps + lib_names,
            swiftc_inputs = swiftc_inputs,
            features = ["swift.no_generated_module_map"],
            tags = tags_manual,
            **kwargs
        )
        lib_names += [swift_libname]
        if module_map:
            extend_modulemap(
                name = module_map + ".extended." + name,
                destination = "%s.extended.modulemap" % name,
                source = module_map,
                swift_header = generated_header_name,
                module_name = module_name,
                tags = _MANUAL,
            )
            module_map = "%s.extended.modulemap" % name

    if cpp_sources and False:
        cc_library(
            name = cpp_libname,
            srcs = cpp_sources + objc_private_hdrs,
            hdrs = objc_hdrs,
            copts = cc_copts,
            deps = deps,
            tags = tags_manual,
        )
        lib_names += [cpp_libname]

    objc_library_data = library_tools["wrap_resources_in_filegroup"](name = objc_libname + "_data", srcs = data)
    objc_library(
        name = objc_libname,
        srcs = objc_sources + objc_private_hdrs + objc_non_exported_hdrs,
        non_arc_srcs = objc_non_arc_sources,
        hdrs = objc_hdrs,
        copts = objc_copts,
        deps = deps + internal_deps + lib_names,
        module_map = module_map,
        sdk_dylibs = sdk_dylibs,
        sdk_frameworks = sdk_frameworks,
        weak_sdk_frameworks = weak_sdk_frameworks,
        sdk_includes = sdk_includes,
        pch = pch,
        data = [objc_library_data],
        tags = tags_manual,
        **kwargs
    )
    launch_screen_storyboard_name = name + "_launch_screen_storyboard"
    native.filegroup(
        name = launch_screen_storyboard_name,
        srcs = [objc_library_data],
        output_group = "launch_screen_storyboard",
        tags = _MANUAL,
    )
    lib_names += [objc_libname]

    if export_private_headers:
        private_headers_name = "%s_private_headers" % name
        lib_names += [private_headers_name]
        _private_headers(name = private_headers_name, headers = objc_private_hdrs, tags = _MANUAL)

    return struct(
        lib_names = lib_names,
        transitive_deps = deps,
        deps = lib_names + deps,
        module_name = module_name,
        launch_screen_storyboard_name = launch_screen_storyboard_name,
        namespace = namespace,
        linkopts = linkopts,
    )
