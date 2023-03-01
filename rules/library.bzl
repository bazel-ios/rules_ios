"""Library rules"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:sets.bzl", "sets")
load("@bazel_skylib//lib:selects.bzl", "selects")
load("@build_bazel_rules_apple//apple:apple.bzl", "apple_dynamic_framework_import", "apple_static_framework_import")
load("@build_bazel_rules_apple//apple/internal/resource_rules:apple_intent_library.bzl", "apple_intent_library")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("//rules:precompiled_apple_resource_bundle.bzl", "precompiled_apple_resource_bundle")
load("//rules:hmap.bzl", "headermap")
load("//rules/framework:vfs_overlay.bzl", "framework_vfs_overlay", VFS_OVERLAY_FRAMEWORK_SEARCH_PATH = "FRAMEWORK_SEARCH_PATH")
load("//rules/library:resources.bzl", "wrap_resources_in_filegroup")
load("//rules/library:xcconfig.bzl", "copts_by_build_setting_with_defaults")
load("//rules:import_middleman.bzl", "import_middleman")
load("//rules:utils.bzl", "bundle_identifier_for_bundle")

PrivateHeadersInfo = provider(
    doc = "Propagates private headers, so they can be accessed if necessary",
    fields = {
        "headers": "Private headers",
    },
)

GLOBAL_INDEX_STORE_PATH = "bazel-out/_global_index_store"

_MANUAL = ["manual"]

def _private_headers_impl(ctx):
    return [
        PrivateHeadersInfo(
            headers = depset(direct = ctx.files.headers),
        ),
        apple_common.new_objc_provider(),
        CcInfo(
            compilation_context = cc_common.create_compilation_context(
                headers = depset(direct = ctx.files.headers),
            ),
        ),
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
        command = "echo \"$1\" | cat \"$2\" - > \"$3\"",
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

def _write_umbrella_header(
        name,
        generate_default_umbrella_header,
        public_headers = [],
        module_name = None):
    basename = "{name}-umbrella.h".format(name = name)
    destination = paths.join(name + "-modulemap", basename)
    if not module_name:
        module_name = name

    content = ""

    if generate_default_umbrella_header:
        content += """\
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

    if generate_default_umbrella_header:
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

def _generate_resource_bundles(name, library_tools, resource_bundles, platforms):
    bundle_target_names = []
    for bundle_name in resource_bundles:
        target_name = "%s-%s" % (name, bundle_name)
        precompiled_apple_resource_bundle(
            name = target_name,
            bundle_name = bundle_name,
            bundle_id = bundle_identifier_for_bundle(bundle_name),
            resources = [
                library_tools["wrap_resources_in_filegroup"](name = target_name + "_resources", srcs = resource_bundles[bundle_name]),
            ],
            platforms = platforms,
            tags = _MANUAL,
        )
        bundle_target_names.append(target_name)
    return bundle_target_names

def _error_on_default_xcconfig(name, default_xcconfig_name):
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

def _xcframework_slice(*, xcframework_name, identifier, platform, platform_variant, supported_archs, build_type, path, dsym_imports = []):
    linkage, packaging = _xcframework_build_type(**build_type)
    resolved_target_name = "{}-{}".format(xcframework_name, identifier)
    resolved_target_name_vfs_overlay = resolved_target_name + "_vfs"

    def _xcframework_slice_imports(path):
        """
        Returns a tuple of the headers, module map and swiftmodules for the given path in a .xcframework.
        """
        hdrs = native.glob(["%s/**/*.h" % path], allow_empty = True)
        modulemaps = native.glob(["%s/**/*.modulemap" % path], allow_empty = True)
        swiftmodules = native.glob(["%s/**/*.swiftmodule/*.*" % path], allow_empty = True)
        modulemap = modulemaps[0] if modulemaps else None
        return hdrs, modulemap, swiftmodules

    def _make_xcframework_vfs(hdrs, modulemap, swiftmodules, static = False):
        """
        Creates a framework_vfs_overlay with the provided arguments.

        If static is True, the framework_vfs_overlay will be created within the context
        of a static library within a .xcframework.
        """
        imported_framework_name = _find_imported_xcframework_name(hdrs) if static else _find_imported_framework_name(hdrs)
        vfs_framework_name = imported_framework_name if imported_framework_name else xcframework_name
        framework_vfs_overlay(
            name = resolved_target_name_vfs_overlay,
            framework_name = vfs_framework_name,
            modulemap = modulemap,
            swiftmodules = swiftmodules,
            hdrs = hdrs,
            tags = _MANUAL,
            extra_search_paths = None if static else xcframework_name,
        )

    if (linkage, packaging) == ("dynamic", "framework"):
        apple_dynamic_framework_import(
            name = resolved_target_name,
            framework_imports = native.glob(
                [path + "/**/*"],
                exclude = ["**/.DS_Store"],
            ),
            deps = [],
            dsym_imports = dsym_imports,
            tags = _MANUAL,
        )
        import_headers, import_module_map, import_swiftmodules = _xcframework_slice_imports(path)
        _make_xcframework_vfs(import_headers, import_module_map, import_swiftmodules)
    elif (linkage, packaging) == ("static", "framework"):
        apple_static_framework_import(
            name = resolved_target_name,
            framework_imports = native.glob(
                [path + "/**/*"],
                exclude = ["**/.DS_Store"],
            ),
            deps = [],
            tags = _MANUAL,
        )
        import_headers, import_module_map, import_swiftmodules = _xcframework_slice_imports(path)
        _make_xcframework_vfs(import_headers, import_module_map, import_swiftmodules)
    elif (linkage, packaging) == ("static", "library"):
        # For a static library the `path` is the path to the library (`.a`) itself.
        # We need the path to the top-level slice directory so we can find headers, modulemaps and swiftmodules.
        slice_dir = paths.dirname(path)
        import_headers, import_module_map, import_swiftmodules = _xcframework_slice_imports(slice_dir)
        includes = [paths.dirname(f) for f in import_headers] + ["%s/Headers" % slice_dir]
        native.objc_import(
            name = resolved_target_name,
            archives = [path],
            hdrs = import_headers,
            includes = includes,
            tags = _MANUAL,
        )
        _make_xcframework_vfs(import_headers, import_module_map, import_swiftmodules, static = True)
    else:
        fail("Unsupported xcframework slice type {} ({}) in {}".format(
            build_type,
            identifier,
            xcframework_name,
        ))

    return (platform, platform_variant, supported_archs, resolved_target_name, resolved_target_name_vfs_overlay)

def _xcframework(*, library_name, name, slices):
    xcframework_name = "{}-import-{}.xcframework".format(library_name, name)
    xcframework_name_vfs = xcframework_name + "_vfs"
    conditions = {}
    conditions_vfs = {}
    arm64_ios_device_slice = None
    arm64_simulator_slice = None

    if not slices:
        fail("No slices found for XCFramework {}".format(xcframework_name))

    for slice in slices:
        platform, platform_variant, archs, name, vfs_overlay_target_name = _xcframework_slice(xcframework_name = xcframework_name, **slice)
        platform_setting = "@build_bazel_rules_ios//rules/apple_platform:" + platform

        for arch in archs:
            if platform == "ios":
                if (arch == "armv7s" or arch == "arm64e"):
                    # unsupported platform-arch by rules_apple
                    continue
                elif platform_variant == "maccatalyst":
                    # TODO: support maccatalyst
                    continue
                elif arch == "arm64":
                    if platform_variant == "simulator":
                        arm64_simulator_slice = name

                        # Skip this - it's later defined
                        continue
                    else:
                        arm64_ios_device_slice = name

            rules_apple_platfrom = "darwin" if platform == "macos" else platform
            arch_setting = "@build_bazel_rules_apple//apple:{}_{}".format(rules_apple_platfrom, arch)
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
            if config_setting_name in conditions_vfs:
                fail("Duplicate slice for {}.xcframework used by {} ({}): {} and {}".format(
                    vfs_overlay_target_name,
                    library_name,
                    config_setting_name,
                    conditions[config_setting_name],
                    vfs_overlay_target_name,
                ))
            conditions[config_setting_name] = name
            conditions_vfs[config_setting_name] = vfs_overlay_target_name
            selects.config_setting_group(
                name = config_setting_name,
                match_all = [platform_setting, arch_setting],
            )

    # Use the arm64 slice when overriding the CPU
    alias_slice = arm64_simulator_slice if arm64_simulator_slice else arm64_ios_device_slice
    if alias_slice:
        native.alias(name = xcframework_name + "default", actual = select(conditions), tags = _MANUAL)
        native.alias(name = xcframework_name + "default_vfs", actual = select(conditions_vfs), tags = _MANUAL)

        conditions = {
            "//conditions:default": xcframework_name + "default",
            "@build_bazel_rules_ios//:arm64_simulator_use_device_deps": alias_slice,
        }
        conditions_vfs = {
            "//conditions:default": xcframework_name + "default_vfs",
            "@build_bazel_rules_ios//:arm64_simulator_use_device_deps": alias_slice + "_vfs",
        }

    native.alias(
        name = xcframework_name,
        actual = select(conditions, no_match_error = "Unable to find a matching slice for {}.xcframework used by {}".format(
            name,
            library_name,
        )),
        tags = _MANUAL,
    )
    native.alias(
        name = xcframework_name_vfs,
        actual = select(conditions_vfs, no_match_error = "Unable to find a matching vfs overlay for {}.xcframework used by {}".format(
            name,
            library_name,
        )),
        tags = _MANUAL,
    )
    return xcframework_name, xcframework_name_vfs

def _find_imported_framework_name(outputs):
    """
    Returns the name of the .framework that includes the given outputs.

    Note: safely assume for an import the paths will be relative to the .framework directory
    (afterall, that is what a .framework means)
    """
    for output in outputs:
        if not ".framework" in output:
            continue
        prefix = output.split(".framework/")[0]
        fw_name = prefix.split("/")[-1]
        return fw_name
    return None

def _find_imported_xcframework_name(outputs):
    """
    Returns the name of the .xcframework that includes the given outputs.

    Note: for a static library there is no .framework.
    Instead, the .xcframework is the name of the static library.
    """
    for output in outputs:
        if not ".xcframework" in output:
            continue
        prefix = output.split(".xcframework/")[0]
        fw_name = prefix.split("/")[-1]
        return fw_name
    return None

def apple_library(name, library_tools = {}, export_private_headers = True, namespace_is_module_name = True, default_xcconfig_name = None, xcconfig = {}, xcconfig_by_build_setting = {}, objc_defines = [], swift_defines = [], **kwargs):
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
        objc_defines: A list of Objective-C defines to add to the compilation command line. They should be in the form KEY=VALUE or simply KEY and are passed not only to the compiler for this target (as copts are) but also to all objc_ dependers of this target.
        swift_defines: A list of Swift defines to add to the compilation command line. Swift defines do not have values, so strings in this list should be simple identifiers and not KEY=VALUE pairs. (only expections are KEY=1 and KEY=0). These flags are added for the target and every target that depends on it.
        **kwargs: keyword arguments.

    Returns:
        Struct with a bunch of info
    """
    library_tools = dict(_DEFAULT_LIBRARY_TOOLS, **library_tools)
    swift_sources = []
    objc_sources = []
    objc_non_arc_sources = []
    cpp_sources = []
    intent_sources = []
    public_headers = kwargs.pop("public_headers", [])
    private_headers = kwargs.pop("private_headers", [])
    objc_hdrs = [f for f in public_headers if f.endswith((".inc", ".h", ".hh", ".hpp"))]
    objc_non_exported_hdrs = []
    objc_private_hdrs = [f for f in private_headers if f.endswith((".inc", ".h", ".hh", ".hpp"))]
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
        if f.endswith((".h", ".hh", ".hpp")):
            if (private_headers and sets.contains(private_headers, f)) or \
               (public_headers and sets.contains(public_headers, f)):
                pass
            elif public_headers and private_headers:
                objc_non_exported_hdrs.append(f)
            elif public_headers:
                objc_private_hdrs.append(f)
            else:
                objc_hdrs.append(f)
        elif f.endswith((".inc", ".m", ".mm", ".c", ".s", ".S")):
            objc_sources.append(f)
        elif f.endswith((".swift")):
            swift_sources.append(f)
        elif f.endswith((".cc", ".cpp")):
            cpp_sources.append(f)
        elif f.endswith((".intentdefinition")):
            intent_sources.append(f)
        else:
            fail("Unable to compile %s in apple_framework %s" % (f, name))

    module_name = kwargs.pop("module_name", name)
    namespace = module_name if namespace_is_module_name else name
    module_map = kwargs.pop("module_map", None)
    swift_objc_bridging_header = kwargs.pop("swift_objc_bridging_header", None)

    # Historically, xcode and cocoapods use an umbrella header that imports Foundation and UIKit at the
    # beginning of it. See:
    # * https://github.com/CocoaPods/CocoaPods/issues/6815#issuecomment-330046236
    # * https://github.com/facebookarchive/xcbuild/issues/92#issuecomment-234372926
    #
    # As a result, when writing swift code, both Foundation and UIKit get imported automatically. See:
    # * https://github.com/facebookarchive/xcbuild/issues/92#issuecomment-234400427
    #
    # But these automatic imports are a problem when strict imports are wanted. See:
    # * https://forums.swift.org/t/supporting-strict-imports/42472
    #
    # So provide here two behaviours:
    # * By default, follow xcode and cocoapods and populate the umbrella header with the usual content
    # * Optionally, allow the consumers to set generate_default_umbrella_header to False, so the
    #   generated umbrella header does not contain any imports
    generate_default_umbrella_header = kwargs.pop("generate_default_umbrella_header", True)
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
    private_dep_names = []
    lib_names = []
    fetch_default_xcconfig = library_tools["fetch_default_xcconfig"](name, default_xcconfig_name, **kwargs) if default_xcconfig_name else {}
    copts_by_build_setting = copts_by_build_setting_with_defaults(xcconfig, fetch_default_xcconfig, xcconfig_by_build_setting)
    enable_framework_vfs = kwargs.pop("enable_framework_vfs", False) or namespace_is_module_name
    defines = kwargs.pop("defines", [])
    testonly = kwargs.pop("testonly", False)
    features = kwargs.pop("features", [])

    for (k, v) in {"momc_copts": momc_copts, "mapc_copts": mapc_copts, "ibtool_copts": ibtool_copts}.items():
        if v:
            fail("Specifying {attr} for {name} is not yet supported. Given: {opts}".format(
                attr = k,
                name = name,
                opts = repr(v),
            ))

    # Generate code for `.intentdefinition` source files and forward the original plist as data
    for intent in intent_sources:
        intent_name = "%s_%s_gen" % (name, intent)

        # Avoid swift_intent_library and objc_intent_library because they wrap the generated code in a new module
        #
        # If other Swift sources are present, generate Swift intent code, otherwise use Obj-C.
        # This mimics the behavior for INTENTS_CODEGEN_LANGUAGE="automatic" in Xcode.
        if len(swift_sources) > 0:
            apple_intent_library(
                name = intent_name,
                src = intent,
                language = "Swift",
                tags = _MANUAL,
                testonly = testonly,
            )

            swift_sources.append(intent_name)
            data.append(intent)

        else:
            intent_sources = "%s_srcs" % intent_name

            intent_public_header = paths.split_extension(intent)[0]

            apple_intent_library(
                name = intent_name,
                src = intent,
                header_name = intent_public_header,
                language = "Objective-C",
                tags = _MANUAL,
                testonly = testonly,
            )

            objc_hdrs.append(intent_name)
            objc_sources.append(intent_name)
            data.append(intent)

    if linkopts:
        linkopts_name = "%s_linkopts" % (name)

        # https://docs.bazel.build/versions/master/be/c-cpp.html#cc_library
        native.cc_library(
            name = linkopts_name,
            linkopts = copts_by_build_setting.linkopts + linkopts,
        )
        private_dep_names.append(linkopts_name)

    vendored_deps = []
    import_vfsoverlays = []

    # There are some frameworks imported with private headers - this is totally
    # expected.
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

        import_headers = native.glob(
            ["%s/**/*.h" % vendored_static_framework],
        )
        import_module_maps = native.glob(
            ["%s/**/*.modulemap" % vendored_static_framework],
            allow_empty = True,
        )
        import_swiftmodules = native.glob(
            ["%s/**/*.swiftmodule/*.*" % vendored_static_framework],
            allow_empty = True,
        )
        vfs_root = vendored_static_framework
        if len(import_module_maps) > 0:
            import_module_map = import_module_maps[0]
        else:
            import_module_map = None

        vfs_imported_framework = _find_imported_framework_name(import_headers)
        vfs_framework_name = vfs_imported_framework if vfs_imported_framework else namespace
        framework_vfs_overlay(
            name = import_name + "_vfs",
            framework_name = vfs_framework_name,
            modulemap = import_module_map,
            swiftmodules = import_swiftmodules,
            hdrs = import_headers,
            tags = _MANUAL,
            testonly = testonly,
            extra_search_paths = vfs_root,
        )
        import_vfsoverlays.append(import_name + "_vfs")
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
        import_headers = native.glob(
            ["%s/**/*.h" % vendored_dynamic_framework],
        )
        import_module_maps = native.glob(
            ["%s/**/*.modulemap" % vendored_dynamic_framework],
            allow_empty = True,
        )
        import_swiftmodules = native.glob(
            ["%s/**/*.swiftmodule/*.*" % vendored_dynamic_framework],
            allow_empty = True,
        )
        if len(import_module_maps) > 0:
            import_module_map = import_module_maps[0]
        else:
            import_module_map = None

        vfs_root = vendored_dynamic_framework

        vfs_imported_framework = _find_imported_framework_name(import_headers)
        vfs_framework_name = vfs_imported_framework if vfs_imported_framework else namespace
        framework_vfs_overlay(
            name = import_name + "_vfs",
            framework_name = vfs_framework_name,
            modulemap = import_module_map,
            swiftmodules = import_swiftmodules,
            hdrs = import_headers,
            tags = _MANUAL,
            testonly = testonly,
            extra_search_paths = vfs_root,
        )
        import_vfsoverlays.append(import_name + "_vfs")

    for vendored_static_library in kwargs.pop("vendored_static_libraries", []):
        import_name = "%s-%s-library-import" % (name, paths.basename(vendored_static_library))
        native.objc_import(
            name = import_name,
            archives = [vendored_static_library],
            tags = _MANUAL,
        )
        vendored_deps.append(import_name)
        import_headers = native.glob(
            ["**/*.h"],
        )
        import_module_maps = native.glob(
            ["**/*.modulemap"],
            allow_empty = True,
        )
        import_swiftmodules = native.glob(
            ["**/*.swiftmodule/*.*"],
            allow_empty = True,
        )
        if len(import_module_maps) > 0:
            import_module_map = import_module_maps[0]
        else:
            import_module_map = None
        vfs_imported_framework = _find_imported_framework_name(import_headers)
        vfs_framework_name = vfs_imported_framework if vfs_imported_framework else namespace
        framework_vfs_overlay(
            name = import_name + "_vfs",
            framework_name = vfs_framework_name,
            modulemap = import_module_map,
            swiftmodules = import_swiftmodules,
            hdrs = import_headers,
            tags = _MANUAL,
            testonly = testonly,
        )
        import_vfsoverlays.append(import_name + "_vfs")

    for xcframework in kwargs.pop("vendored_xcframeworks", []):
        xcframework_name, xcframework_name_vfs = _xcframework(library_name = name, **xcframework)
        vendored_deps.append(xcframework_name)
        import_vfsoverlays.append(xcframework_name_vfs)

    # We don't currently support dynamic library
    for vendored_dynamic_library in kwargs.pop("vendored_dynamic_libraries", []):
        fail("no support for dynamic library: %s" % vendored_dynamic_library)

    # TODO(jmarino)Perhaps it uses a import_middleman here
    if len(vendored_deps):
        import_middleman(name = name + ".import_middleman", deps = vendored_deps, tags = ["manual"])
        deps += select({
            "@build_bazel_rules_ios//:arm64_simulator_use_device_deps": [name + ".import_middleman"],
            "//conditions:default": vendored_deps,
        })

    resource_bundles = library_tools["resource_bundle_generator"](
        name = name,
        library_tools = library_tools,
        resource_bundles = kwargs.pop("resource_bundles", {}),
        platforms = platforms,
    )
    deps += resource_bundles

    objc_libname = "%s_objc" % name
    swift_libname = "%s_swift" % name
    cpp_libname = "%s_cpp" % name

    framework_vfs_overlay_name = name + "_vfs"
    framework_vfs_overlay_name_swift = swift_libname + "_vfs"

    # TODO: remove under certian circumstances when framework if set
    # Needs to happen before headermaps are made, so the generated umbrella header gets added to those headermaps
    has_compile_srcs = (objc_hdrs or objc_private_hdrs or swift_sources or objc_sources or cpp_sources)
    generate_umbrella_module = (namespace_is_module_name and has_compile_srcs)
    if generate_umbrella_module:
        if not module_map:
            umbrella_header = library_tools["umbrella_header_generator"](
                name = name,
                generate_default_umbrella_header = generate_default_umbrella_header,
                public_headers = objc_hdrs,
                module_name = module_name,
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

    framework_vfs_overlay(
        name = framework_vfs_overlay_name_swift,
        framework_name = module_name,
        modulemap = module_map,
        has_swift = len(swift_sources) > 0,
        private_hdrs = objc_private_hdrs,
        hdrs = objc_hdrs,
        tags = _MANUAL,
        testonly = testonly,
        deps = deps + private_deps + private_dep_names + lib_names + import_vfsoverlays,
    )

    framework_vfs_objc_copts = [
        "-ivfsoverlay$(execpath :{})".format(framework_vfs_overlay_name),
        "-F{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
    ]
    framework_vfs_swift_copts = [
        "-Xfrontend",
        "-vfsoverlay$(execpath :{})".format(framework_vfs_overlay_name_swift),
        "-Xfrontend",
        "-F{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
        "-I{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
        "-Xcc",
        "-ivfsoverlay$(execpath :{})".format(framework_vfs_overlay_name_swift),
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
    private_dep_names.append(public_hmap_name)

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
    private_dep_names.append(private_hmap_name)
    headermap(
        name = private_angled_hmap_name,
        namespace = namespace,
        hdrs = [private_angled_hdrs_filegroup],
        tags = _MANUAL,
    )
    private_dep_names.append(private_angled_hmap_name)

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

    module_data = library_tools["wrap_resources_in_filegroup"](name = name + "_wrapped_resources_filegroup", srcs = data, testonly = testonly)

    if swift_sources:
        additional_swift_copts.extend(("-Xcc", "-I."))
        if module_map:
            # Frameworks find the modulemap file via the framework vfs overlay
            if not namespace_is_module_name:
                additional_swift_copts += ["-Xcc", "-fmodule-map-file=" + "$(execpath " + module_map + ")"]
            additional_swift_copts.append(
                "-import-underlying-module",
            )
        swiftc_inputs = other_inputs + objc_hdrs + objc_private_hdrs
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

    # Note: this needs to go here, in order to virtualize the extended module
    framework_vfs_overlay(
        name = framework_vfs_overlay_name,
        framework_name = module_name,
        has_swift = len(swift_sources) > 0,
        modulemap = module_map,
        private_hdrs = objc_private_hdrs,
        hdrs = objc_hdrs,
        tags = _MANUAL,
        testonly = testonly,
        deps = deps + private_deps + private_dep_names + lib_names + import_vfsoverlays,
        #enable_framework_vfs = enable_framework_vfs
    )

    if swift_sources:
        swift_library(
            name = swift_libname,
            module_name = module_name,
            generated_header_name = generated_swift_header_name,
            generates_header = True,
            srcs = swift_sources,
            # Note: by default it used a vfs but not the entire virtual framwork
            # feature.
            copts = copts_by_build_setting.swift_copts + swift_copts + select({
                "@build_bazel_rules_ios//:virtualize_frameworks": framework_vfs_swift_copts,
                "//conditions:default": framework_vfs_swift_copts if enable_framework_vfs else [],
            }) + additional_swift_copts,
            deps = deps + private_deps + private_dep_names + lib_names + select({
                "@build_bazel_rules_ios//:virtualize_frameworks": [framework_vfs_overlay_name_swift],
                "//conditions:default": [framework_vfs_overlay_name_swift] if enable_framework_vfs else [],
            }),
            swiftc_inputs = swiftc_inputs,
            features = features + ["swift.no_generated_module_map", "swift.use_pch_output_dir"] + select({
                "@build_bazel_rules_ios//:virtualize_frameworks": ["swift.vfsoverlay"],
                "//conditions:default": [],
            }),
            data = [module_data],
            tags = tags_manual,
            defines = defines + swift_defines,
            testonly = testonly,
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
            testonly = testonly,
        )
        private_dep_names.append(swift_doublequote_hmap_name)
        _append_headermap_copts(swift_doublequote_hmap_name, "-iquote", additional_objc_copts, additional_swift_copts, additional_cc_copts)

        # Add generated swift header to header maps for double quote imports
        swift_angle_bracket_hmap_name = name + "_swift_angle_bracket_hmap"
        headermap(
            name = swift_angle_bracket_hmap_name,
            namespace = namespace,
            hdrs = [],
            direct_hdr_providers = [swift_libname],
            tags = _MANUAL,
            testonly = testonly,
        )
        private_dep_names.append(swift_angle_bracket_hmap_name)
        _append_headermap_copts(swift_angle_bracket_hmap_name, "-I", additional_objc_copts, additional_swift_copts, additional_cc_copts)

    # Note: this line is intentionally disabled
    if cpp_sources:
        additional_cc_copts.append("-I.")
        native.objc_library(
            name = cpp_libname,
            srcs = cpp_sources + objc_private_hdrs + objc_non_exported_hdrs,
            hdrs = objc_hdrs,
            copts = copts_by_build_setting.cc_copts + cc_copts + additional_cc_copts,
            deps = deps + private_deps + private_dep_names,
            defines = defines,
            tags = tags_manual,
            testonly = testonly,
            features = features,
        )
        lib_names.append(cpp_libname)

    additional_objc_copts.append("-I.")
    index_while_building_objc_copts = select({
        "@build_bazel_rules_ios//:use_global_index_store": [
            # Note: this won't work work for remote caching yet. It uses a
            # _different_ global index for objc than so that the BEP grep in
            # rules_ios picks this up.
            # Checkout the task roadmap for future improvements:
            # Docs/index_while_building.md
            "-index-store-path",
            GLOBAL_INDEX_STORE_PATH,
        ],
        "//conditions:default": [
            "-index-store-path",
            "$(GENDIR)/{package}/rules_ios_objc_library_{libname}.indexstore".format(
                package = native.package_name(),
                libname = objc_libname,
            ),
        ],
    })

    additional_objc_vfs_deps = select({
        "@build_bazel_rules_ios//:virtualize_frameworks": [framework_vfs_overlay_name_swift] + [framework_vfs_overlay_name],
        "//conditions:default": [framework_vfs_overlay_name_swift] + [framework_vfs_overlay_name] if enable_framework_vfs else [],
    })
    additional_objc_vfs_copts = select({
        "@build_bazel_rules_ios//:virtualize_frameworks": framework_vfs_objc_copts,
        "//conditions:default": framework_vfs_objc_copts if enable_framework_vfs else [],
    })
    if module_map:
        objc_hdrs.append(module_map)

    native.objc_library(
        name = objc_libname,
        srcs = objc_sources + objc_private_hdrs + objc_non_exported_hdrs,
        non_arc_srcs = objc_non_arc_sources,
        hdrs = objc_hdrs,
        copts = copts_by_build_setting.objc_copts + objc_copts + additional_objc_vfs_copts + additional_objc_copts + index_while_building_objc_copts,
        deps = deps + private_deps + private_dep_names + lib_names + additional_objc_vfs_deps,
        module_map = module_map,
        sdk_dylibs = sdk_dylibs,
        sdk_frameworks = sdk_frameworks,
        weak_sdk_frameworks = weak_sdk_frameworks,
        sdk_includes = sdk_includes,
        pch = pch,
        data = [] if swift_sources else [module_data],
        tags = tags_manual,
        defines = defines + objc_defines,
        testonly = testonly,
        features = features,
        **kwargs
    )
    launch_screen_storyboard_name = name + "_launch_screen_storyboard"
    native.filegroup(
        name = launch_screen_storyboard_name,
        srcs = [module_data],
        output_group = "launch_screen_storyboard",
        tags = _MANUAL,
        testonly = testonly,
    )
    lib_names.append(objc_libname)

    if export_private_headers:
        private_headers_name = "%s_private_headers" % name
        lib_names.append(private_headers_name)
        _private_headers(name = private_headers_name, headers = objc_private_hdrs, tags = _MANUAL)

    return struct(
        lib_names = lib_names,
        import_vfsoverlays = import_vfsoverlays,
        transitive_deps = deps,
        deps = lib_names + deps,
        module_name = module_name,
        data = module_data,
        launch_screen_storyboard_name = launch_screen_storyboard_name,
        namespace = namespace,
        linkopts = copts_by_build_setting.linkopts + linkopts,
        platforms = platforms,
        has_swift_sources = (swift_sources and len(swift_sources) > 0),
    )
