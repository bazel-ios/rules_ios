"""Library rules"""

load("@rules_cc//cc:defs.bzl", "cc_library", "objc_import", "objc_library")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:sets.bzl", "sets")
load("@bazel_skylib//lib:selects.bzl", "selects")
load("@build_bazel_rules_apple//apple:apple.bzl", "apple_dynamic_framework_import", "apple_static_framework_import")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("//rules:precompiled_apple_resource_bundle.bzl", "precompiled_apple_resource_bundle")
load("//rules:hmap.bzl", "headermap")
load("//rules/framework:vfs_overlay.bzl", "framework_vfs_overlay", VFS_OVERLAY_FRAMEWORK_SEARCH_PATH = "FRAMEWORK_SEARCH_PATH")
load("//rules/library:resources.bzl", "wrap_resources_in_filegroup")
load("//rules/library:xcconfig.bzl", "copts_by_build_setting_with_defaults")

PrivateHeadersInfo = provider(
    doc = "Propagates private headers, so they can be accessed if necessary",
    fields = {
        "headers": "Private headers",
    },
)

_MANUAL = ["manual"]

def _private_headers_impl(ctx):
    return [
        PrivateHeadersInfo(
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
        "content": attr.string(mandatory = True),
        "destination": attr.output(mandatory = True),
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
        command = "echo \"$1\" | cat $2 - > $3",
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

def _write_modulemap(name, library_tools, umbrella_header = None, public_headers = [], private_headers = [], module_name = None, framework = False, **kwargs):
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

def _write_umbrella_header(name, library_tools, public_headers = [], private_headers = [], module_name = None, **kwargs):
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

def _generate_resource_bundles(name, library_tools, module_name, resource_bundles, platforms, **kwargs):
    bundle_target_names = []
    for bundle_name in resource_bundles:
        target_name = "%s-%s" % (name, bundle_name)
        precompiled_apple_resource_bundle(
            name = target_name,
            bundle_name = bundle_name,
            resources = [
                library_tools["wrap_resources_in_filegroup"](name = target_name + "_resources", srcs = resource_bundles[bundle_name]),
            ],
            platforms = platforms,
            tags = _MANUAL,
        )
        bundle_target_names.append(target_name)
    return bundle_target_names

def _error_on_default_xcconfig(name, library_tools, default_xcconfig_name, **kwargs):
    fail("{name} specifies a default xcconfig ({default_xcconfig_name}). You must override fetch_default_xcconfig to use this feature.".format(
        name = name,
        default_xcconfig_name = default_xcconfig_name,
    ))

_DEFAULT_LIBRARY_TOOLS = {
    "modulemap_generator": _write_modulemap,
    "umbrella_header_generator": _write_umbrella_header,
    "resource_bundle_generator": _generate_resource_bundles,
    "wrap_resources_in_filegroup": wrap_resources_in_filegroup,
    "fetch_default_xcconfig": _error_on_default_xcconfig,
}

def _append_headermap_copts(hmap, flag, objc_copts, swift_copts, cc_copts):
    copt = flag + "$(execpath :{hmap})".format(hmap = hmap)

    objc_copts.append(copt)
    cc_copts.append(copt)
    swift_copts.extend(("-Xcc", copt))

def _uppercase_string(s):
    return s.upper()

def _canonicalize_swift_version(swift_version):
    if not swift_version:
        return None

    version_parts = swift_version.split(".", 2)

    if int(version_parts[0]) >= 5:
        # Swift 5+ doesn't allow the minor version to be supplied, though Xcode is more lenient
        swift_version = version_parts[0]
    else:
        # Drop any trailing ".0" versions
        version_parts_scrubbed = []
        only_zeros_seen = True
        for part in reversed(version_parts):
            if part == "0" and only_zeros_seen:
                continue
            only_zeros_seen = False
            version_parts_scrubbed.insert(0, part)
        swift_version = ".".join(version_parts_scrubbed)

    return swift_version

def _xcframework_build_type(*, linkage, packaging):
    return (linkage, packaging)

def _xcframework_slice(*, xcframework_name, identifier, platform, platform_variant, supported_archs, build_type, path):
    linkage, packaging = _xcframework_build_type(**build_type)
    import_name = "{}-{}".format(xcframework_name, identifier)
    if (linkage, packaging) == ("dynamic", "framework"):
        apple_dynamic_framework_import(
            name = import_name,
            framework_imports = native.glob(
                [path + "/**/*"],
                exclude = ["**/.DS_Store"],
            ),
            deps = [],
            tags = _MANUAL,
        )
    elif (linkage, packaging) == ("static", "framework"):
        apple_static_framework_import(
            name = import_name,
            framework_imports = native.glob(
                [path + "/**/*"],
                exclude = ["**/.DS_Store"],
            ),
            deps = [],
            tags = _MANUAL,
        )
    elif (linkage, packaging) == ("static", "library"):
        objc_import(
            name = import_name,
            archives = [path],
            tags = _MANUAL,
        )
    else:
        fail("Unsupported xcframework slice type {} ({}) in {}".format(
            build_type,
            identifier,
            xcframework_name,
        ))
    return (platform, platform_variant, supported_archs, import_name)

def _xcframework(*, library_name, name, slices):
    xcframework_name = "{}-import-{}.xcframework".format(library_name, name)
    conditions = {}
    for slice in slices:
        platform, platform_variant, archs, name = _xcframework_slice(xcframework_name = xcframework_name, **slice)
        platform_setting = "@build_bazel_rules_ios//rules/apple_platform:" + platform
        # platform_variant_setting = "@build_bazel_rules_ios//rules/apple_platform:platform_variant_" + platform_variant if platform_variant else None

        for arch in archs:
            if arch == "arm64" and platform_variant == "simulator":
                # TODO: support sim on apple silicon by having a config setting for platform_variant
                continue
            elif arch == "x86_64" and platform_variant == "maccatalyst":
                # TODO: support maccatalyst
                continue

            arch_setting = "@build_bazel_rules_apple//apple:{}_{}".format(platform, arch)
            config_setting_name = "{}-{}".format(
                xcframework_name,
                "_".join([x for x in (platform, platform_variant, arch) if x]),
            )
            if config_setting_name in conditions:
                fail("Duplicate slice for {}.xcframework used by {} ({}): {} and {}".format(
                    name,
                    library_name,
                    config_setting_name,
                    conditions[config_setting_name],
                    name,
                ))
            conditions[config_setting_name] = name
            selects.config_setting_group(
                name = config_setting_name,
                match_all = [platform_setting, arch_setting],
            )

    native.alias(
        name = xcframework_name,
        actual = select(conditions, no_match_error = "Unable to find a matching slice for {}.xcframework used by {}".format(
            name,
            library_name,
        )),
        tags = _MANUAL,
    )
    return xcframework_name

def apple_library(name, library_tools = {}, export_private_headers = True, namespace_is_module_name = True, default_xcconfig_name = None, xcconfig = {}, xcconfig_by_build_setting = {}, **kwargs):
    """Create libraries for native source code on Apple platforms.

    Automatically handles mixed-source libraries and comes with
    reasonable defaults that mimic Xcode's behavior.

    Args:
        name: The base name for all of the underlying targets.
        library_tools:  An optional dictionary containing overrides for
                        default behaviors.
        export_private_headers: Whether private headers should be exported via
                                a `PrivateHeadersInfo` provider.
        namespace_is_module_name: Whether the module name should be used as the
                                  namespace for header imports, instead of the target name.
        default_xcconfig_name: The name of a default xcconfig to be applied to this target.
        xcconfig: A dictionary of Xcode build settings to be applied to this target in the
                  form of different `copt` attributes.
        xcconfig_by_build_setting: A dictionary of Xcode build settings grouped by bazel build setting.

                                   Each value is applied (overriding any matching setting in 'xcconfig') if
                                   the respective bazel build setting is resolved during the analysis phase.
        **kwargs: keyword arguments.

    Returns:
        Struct with a bunch of info
    """
    library_tools = dict(_DEFAULT_LIBRARY_TOOLS, **library_tools)
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
    swift_objc_bridging_header = kwargs.pop("swift_objc_bridging_header", None)
    cc_copts = kwargs.pop("cc_copts", [])
    additional_cc_copts = []
    swift_copts = kwargs.pop("swift_copts", [])
    additional_swift_copts = []
    ibtool_copts = kwargs.pop("ibtool_copts", [])
    momc_copts = kwargs.pop("momc_copts", [])
    mapc_copts = kwargs.pop("mapc_copts", [])
    linkopts = kwargs.pop("linkopts", [])
    objc_copts = kwargs.pop("objc_copts", [])
    additional_objc_copts = []
    other_inputs = kwargs.pop("other_inputs", [])
    sdk_dylibs = kwargs.pop("sdk_dylibs", [])
    sdk_frameworks = kwargs.pop("sdk_frameworks", [])
    weak_sdk_frameworks = kwargs.pop("weak_sdk_frameworks", [])
    sdk_includes = kwargs.pop("sdk_includes", [])
    pch = kwargs.pop("pch", "@build_bazel_rules_ios//rules/library:common.pch")
    deps = [] + kwargs.pop("deps", [])
    data = kwargs.pop("data", [])
    tags = kwargs.pop("tags", [])
    tags_manual = tags if "manual" in tags else tags + _MANUAL
    platforms = kwargs.pop("platforms", None)
    private_deps = [] + kwargs.pop("private_deps", [])
    lib_names = []
    fetch_default_xcconfig = library_tools["fetch_default_xcconfig"](name, library_tools, default_xcconfig_name, **kwargs) if default_xcconfig_name else {}
    copts_by_build_setting = copts_by_build_setting_with_defaults(xcconfig, fetch_default_xcconfig, xcconfig_by_build_setting)

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
            linkopts = copts_by_build_setting.linkopts + linkopts,
        )
        private_deps.append(linkopts_name)

    vendored_deps = []
    for vendored_static_framework in kwargs.pop("vendored_static_frameworks", []):
        import_name = "%s-%s-import" % (name, paths.basename(vendored_static_framework))
        apple_static_framework_import(
            name = import_name,
            framework_imports = native.glob(
                ["%s/**/*" % vendored_static_framework],
                exclude = ["**/.DS_Store"],
            ),
            tags = _MANUAL,
        )
        vendored_deps.append(import_name)
    for vendored_dynamic_framework in kwargs.pop("vendored_dynamic_frameworks", []):
        import_name = "%s-%s-import" % (name, paths.basename(vendored_dynamic_framework))
        apple_dynamic_framework_import(
            name = import_name,
            framework_imports = native.glob(
                ["%s/**/*" % vendored_dynamic_framework],
                exclude = ["**/.DS_Store"],
            ),
            deps = [],
            tags = _MANUAL,
        )
        vendored_deps.append(import_name)
    for vendored_static_library in kwargs.pop("vendored_static_libraries", []):
        import_name = "%s-%s-library-import" % (name, paths.basename(vendored_static_library))
        objc_import(
            name = import_name,
            archives = [vendored_static_library],
            tags = _MANUAL,
        )
        vendored_deps.append(import_name)
    for vendored_dynamic_library in kwargs.pop("vendored_dynamic_libraries", []):
        fail("no import for %s" % vendored_dynamic_library)
    for xcframework in kwargs.pop("vendored_xcframeworks", []):
        vendored_deps.append(_xcframework(library_name = name, **xcframework))
    deps += vendored_deps

    resource_bundles = library_tools["resource_bundle_generator"](
        name = name,
        library_tools = library_tools,
        resource_bundles = kwargs.pop("resource_bundles", {}),
        module_name = module_name,
        platforms = platforms,
        **kwargs
    )
    deps += resource_bundles

    # TODO: remove framework if set
    # Needs to happen before headermaps are made, so the generated umbrella header gets added to those headermaps
    if namespace_is_module_name and \
       (objc_hdrs or objc_private_hdrs or swift_sources or objc_sources or cpp_sources):
        if not module_map:
            umbrella_header = library_tools["umbrella_header_generator"](
                name = name,
                library_tools = library_tools,
                public_headers = objc_hdrs,
                private_headers = objc_private_hdrs,
                module_name = module_name,
                **kwargs
            )
            if umbrella_header:
                objc_hdrs.append(umbrella_header)
            module_map = library_tools["modulemap_generator"](
                name = name,
                library_tools = library_tools,
                umbrella_header = paths.basename(umbrella_header),
                public_headers = objc_hdrs,
                private_headers = objc_private_hdrs,
                module_name = module_name,
                framework = True,
                **kwargs
            )

        framework_vfs_overlay_name = name + "_vfs"
        framework_vfs_overlay(
            name = framework_vfs_overlay_name,
            framework_name = namespace,
            modulemap = module_map,
            private_hdrs = objc_private_hdrs,
            hdrs = objc_hdrs,
            tags = _MANUAL,
        )
        private_deps.append(framework_vfs_overlay_name)
        additional_objc_copts += [
            "-ivfsoverlay$(execpath :{})".format(framework_vfs_overlay_name),
            "-F{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
        ]
        additional_swift_copts += [
            "-Xcc",
            "-ivfsoverlay$(execpath :{})".format(framework_vfs_overlay_name),
            "-Xcc",
            "-F{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
        ]

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
        tags = _MANUAL,
    )
    private_deps.append(public_hmap_name)

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
        hdrs = [private_hdrs_filegroup],
        tags = _MANUAL,
    )
    private_deps.append(private_hmap_name)
    headermap(
        name = private_angled_hmap_name,
        namespace = namespace,
        hdrs = [private_angled_hdrs_filegroup],
        tags = _MANUAL,
    )
    private_deps.append(private_angled_hmap_name)

    ## END HMAP

    _append_headermap_copts(private_hmap_name, "-I", additional_objc_copts, additional_swift_copts, additional_cc_copts)
    _append_headermap_copts(public_hmap_name, "-I", additional_objc_copts, additional_swift_copts, additional_cc_copts)
    _append_headermap_copts(private_angled_hmap_name, "-I", additional_objc_copts, additional_swift_copts, additional_cc_copts)
    _append_headermap_copts(private_hmap_name, "-iquote", additional_objc_copts, additional_swift_copts, additional_cc_copts)

    additional_objc_copts += [
        "-fmodules",
        "-fmodule-name=%s" % module_name,
    ]

    additional_swift_copts += [
        "-Xcc",
        "-D__SWIFTC__",
        "-Xfrontend",
        "-no-clang-module-breadcrumbs",
    ]

    swift_version = _canonicalize_swift_version(kwargs.pop("swift_version", None))
    if swift_version:
        additional_swift_copts += ["-swift-version", swift_version]

    objc_libname = "%s_objc" % name
    swift_libname = "%s_swift" % name
    cpp_libname = "%s_cpp" % name

    module_data = library_tools["wrap_resources_in_filegroup"](name = module_name + "_data", srcs = data)

    if swift_sources:
        additional_swift_copts.extend(("-Xcc", "-I."))
        if module_map:
            # Frameworks find the modulemap file via the framework vfs overlay
            if not namespace_is_module_name:
                additional_swift_copts += ["-Xcc", "-fmodule-map-file=" + "$(execpath " + module_map + ")"]
            additional_swift_copts.append(
                "-import-underlying-module",
            )
        swiftc_inputs = other_inputs + objc_hdrs
        if module_map:
            swiftc_inputs.append(module_map)
        if swift_objc_bridging_header:
            if swift_objc_bridging_header not in objc_hdrs:
                swiftc_inputs.append(swift_objc_bridging_header)
            additional_swift_copts += [
                "-import-objc-header",
                "$(execpath :{})".format(swift_objc_bridging_header),
            ]
        generated_swift_header_name = module_name + "-Swift.h"

        swift_library(
            name = swift_libname,
            module_name = module_name,
            generated_header_name = generated_swift_header_name,
            srcs = swift_sources,
            copts = copts_by_build_setting.swift_copts + swift_copts + additional_swift_copts,
            deps = deps + private_deps + lib_names,
            swiftc_inputs = swiftc_inputs,
            features = ["swift.no_generated_module_map"],
            data = [module_data],
            tags = tags_manual,
            **kwargs
        )
        lib_names.append(swift_libname)

        # Add generated swift header to header maps for angle bracket imports
        swift_doublequote_hmap_name = name + "_swift_doublequote_hmap"
        headermap(
            name = swift_doublequote_hmap_name,
            namespace = namespace,
            hdrs = [],
            direct_hdr_providers = [swift_libname],
            tags = _MANUAL,
        )
        private_deps.append(swift_doublequote_hmap_name)
        _append_headermap_copts(swift_doublequote_hmap_name, "-iquote", additional_objc_copts, additional_swift_copts, additional_cc_copts)

        # Add generated swift header to header maps for double quote imports
        swift_angle_bracket_hmap_name = name + "_swift_angle_bracket_hmap"
        headermap(
            name = swift_angle_bracket_hmap_name,
            namespace = namespace,
            hdrs = [],
            direct_hdr_providers = [swift_libname],
            tags = _MANUAL,
        )
        private_deps.append(swift_angle_bracket_hmap_name)
        _append_headermap_copts(swift_angle_bracket_hmap_name, "-I", additional_objc_copts, additional_swift_copts, additional_cc_copts)

        if module_map:
            extend_modulemap(
                name = module_map + ".extended." + name,
                destination = "%s.extended.modulemap" % name,
                source = module_map,
                swift_header = generated_swift_header_name,
                module_name = module_name,
                tags = _MANUAL,
            )
            module_map = "%s.extended.modulemap" % name

    if cpp_sources and False:
        additional_cc_copts.append("-I.")
        cc_library(
            name = cpp_libname,
            srcs = cpp_sources + objc_private_hdrs,
            hdrs = objc_hdrs,
            copts = copts_by_build_setting.cc_copts + cc_copts + additional_cc_copts,
            deps = deps,
            tags = tags_manual,
        )
        lib_names.append(cpp_libname)

    additional_objc_copts.append("-I.")
    index_while_building_objc_copts = select({
        "@build_bazel_rules_ios//:index_while_building_v2": [
            # Note: this won't work work for remote caching yet. It uses a
            # _different_ global index for objc than so that the BEP grep in
            # rules_ios picks this up.
            # Checkout the task roadmap for future improvements:
            # Docs/index_while_building.md
            "-index-store-path",
            "bazel-out/rules_ios_global_index_store.indexstore",
        ],
        "//conditions:default": [
            "-index-store-path",
            "$(GENDIR)/{package}/rules_ios_objc_library_{libname}.indexstore".format(
                package = native.package_name(),
                libname = objc_libname,
            ),
        ],
    })

    objc_library(
        name = objc_libname,
        srcs = objc_sources + objc_private_hdrs + objc_non_exported_hdrs,
        non_arc_srcs = objc_non_arc_sources,
        hdrs = objc_hdrs,
        copts = copts_by_build_setting.objc_copts + objc_copts + additional_objc_copts + index_while_building_objc_copts,
        deps = deps + private_deps + lib_names,
        module_map = module_map,
        sdk_dylibs = sdk_dylibs,
        sdk_frameworks = sdk_frameworks,
        weak_sdk_frameworks = weak_sdk_frameworks,
        sdk_includes = sdk_includes,
        pch = pch,
        data = [] if swift_sources else [module_data],
        tags = tags_manual,
        **kwargs
    )
    launch_screen_storyboard_name = name + "_launch_screen_storyboard"
    native.filegroup(
        name = launch_screen_storyboard_name,
        srcs = [module_data],
        output_group = "launch_screen_storyboard",
        tags = _MANUAL,
    )
    lib_names.append(objc_libname)

    if export_private_headers:
        private_headers_name = "%s_private_headers" % name
        lib_names.append(private_headers_name)
        _private_headers(name = private_headers_name, headers = objc_private_hdrs, tags = _MANUAL)

    return struct(
        lib_names = lib_names,
        transitive_deps = deps,
        deps = lib_names + deps,
        module_name = module_name,
        launch_screen_storyboard_name = launch_screen_storyboard_name,
        namespace = namespace,
        linkopts = copts_by_build_setting.linkopts + linkopts,
        platforms = platforms,
        has_swift_sources = (swift_sources and len(swift_sources) > 0),
    )
