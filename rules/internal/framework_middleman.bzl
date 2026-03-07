load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo")
load(
    "@build_bazel_rules_apple//apple/internal:providers.bzl",
    "AppleResourceInfo",
    "IosFrameworkBundleInfo",
    "new_applebundleinfo",
    "new_iosframeworkbundleinfo",
)
load(
    "@build_bazel_rules_apple//apple/internal:partials.bzl",
    "partials",
)
load(
    "@build_bazel_rules_apple//apple/internal:resources.bzl",
    "resources",
)
load(
    "@build_bazel_rules_apple//apple/internal:apple_product_type.bzl",
    "apple_product_type",
)
load(
    "//rules:providers.bzl",
    "AvoidDepsInfo",
)
load(
    "@build_bazel_rules_apple//apple/internal/providers:embeddable_info.bzl",
    "AppleEmbeddableInfo",
    "embeddable_info",
)
load(
    "//rules/internal:objc_provider_utils.bzl",
    "objc_provider_utils",
)
load("//rules:transition_support.bzl", "transition_support")

def _framework_middleman(ctx):
    resource_providers = []
    objc_providers = []
    dynamic_frameworks = []
    dynamic_framework_providers = []
    apple_embeddable_infos = []
    cc_providers = []
    swift_infos = []
    cc_toolchain = find_cpp_toolchain(ctx)
    cc_features = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        language = "objc",
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    def _process_dep(lib_dep):
        if AppleEmbeddableInfo in lib_dep:
            apple_embeddable_infos.append(lib_dep[AppleEmbeddableInfo])

        # Most of these providers will be passed into `deps` of apple rules.
        # Don't feed them twice. There are several assumptions rules_apple on
        # this
        if IosFrameworkBundleInfo in lib_dep:
            if CcInfo in lib_dep:
                cc_providers.append(lib_dep[CcInfo])
            if AppleResourceInfo in lib_dep:
                resource_providers.append(lib_dep[AppleResourceInfo])
        if apple_common.Objc in lib_dep:
            objc_providers.append(lib_dep[apple_common.Objc])
        if SwiftInfo in lib_dep:
            swift_infos.append(lib_dep[SwiftInfo])
            # Also ensure Swift's CcInfo is collected
            if CcInfo in lib_dep and lib_dep not in cc_providers:
                cc_providers.append(lib_dep[CcInfo])
        # Bazel 8 compatibility: Try both old and potential new provider names
        if hasattr(apple_common, "AppleDynamicFramework") and apple_common.AppleDynamicFramework in lib_dep:
            dynamic_frameworks.append(lib_dep)
            dynamic_framework_providers.append(lib_dep[apple_common.AppleDynamicFramework])
        # Note: In Bazel 8, dynamic framework info might be in CcInfo instead

    for dep in ctx.attr.framework_deps:
        _process_dep(dep)

        # Loop AvoidDepsInfo here as well
        if AvoidDepsInfo in dep:
            for lib_dep in dep[AvoidDepsInfo].libraries:
                _process_dep(lib_dep)

    # Here we only need to loop a subset of the keys
    # In Bazel 8, dynamic_framework_file is not supported in ObjcInfo
    # We'll handle it through CcInfo instead
    objc_provider_fields = objc_provider_utils.merge_objc_providers_dict(providers = objc_providers, merge_keys = [])

    # Add the frameworks to the objc provider for Bazel <= 6
    dynamic_framework_provider = objc_provider_utils.merge_dynamic_framework_providers(dynamic_framework_providers)
    # Don't add dynamic_framework_file to ObjcInfo in Bazel 8 - it will be handled via CcInfo
    
    objc_provider = apple_common.new_objc_provider(**objc_provider_fields)

    # Add the framework info to the cc info linking context for Bazel >= 7
    if dynamic_framework_provider and hasattr(dynamic_framework_provider, "framework_files"):
        framework_cc_info = CcInfo(
            linking_context = cc_common.create_linking_context(
                linker_inputs = depset([
                    cc_common.create_linker_input(
                        owner = ctx.label,
                        libraries = depset([
                            cc_common.create_library_to_link(
                                actions = ctx.actions,
                                cc_toolchain = cc_toolchain,
                                feature_configuration = cc_features,
                                dynamic_library = dynamic_library,
                            )
                            for dynamic_library in dynamic_framework_provider.framework_files.to_list()
                        ]),
                    ),
                ]),
            ),
        )
        cc_info_provider = cc_common.merge_cc_infos(direct_cc_infos = [framework_cc_info], cc_infos = cc_providers)
    else:
        cc_info_provider = cc_common.merge_cc_infos(cc_infos = cc_providers)

    # Bazel 8 compatibility: Collect libraries from ObjcInfo and add to CcInfo
    # This ensures all libraries (including .lo files) are properly linked
    additional_libraries = []
    for objc_p in objc_providers:
        # Collect regular libraries
        if hasattr(objc_p, "library"):
            additional_libraries.extend(objc_p.library.to_list())
        # Collect force_load libraries (critical for alwayslink)
        if hasattr(objc_p, "force_load_library"):
            additional_libraries.extend(objc_p.force_load_library.to_list())
        # Collect imported libraries
        if hasattr(objc_p, "imported_library"):
            additional_libraries.extend(objc_p.imported_library.to_list())
        # Collect static framework files
        if hasattr(objc_p, "static_framework_file"):
            additional_libraries.extend(objc_p.static_framework_file.to_list())
    
    # If we found additional libraries not in CcInfo, add them
    if additional_libraries:
        # Create library_to_link for each additional library
        libraries_to_link = []
        for lib in additional_libraries:
            # Check if it's a static library (.a or .lo)
            if lib.path.endswith(".a") or lib.path.endswith(".lo"):
                libraries_to_link.append(
                    cc_common.create_library_to_link(
                        actions = ctx.actions,
                        cc_toolchain = cc_toolchain,
                        feature_configuration = cc_features,
                        static_library = lib,
                        alwayslink = lib.path.endswith(".lo"),  # .lo files are alwayslink
                    )
                )
        
        if libraries_to_link:
            additional_cc_info = CcInfo(
                linking_context = cc_common.create_linking_context(
                    linker_inputs = depset([
                        cc_common.create_linker_input(
                            owner = ctx.label,
                            libraries = depset(libraries_to_link),
                        ),
                    ]),
                ),
            )
            cc_info_provider = cc_common.merge_cc_infos(
                direct_cc_infos = [additional_cc_info],
                cc_infos = [cc_info_provider],
            )

    providers = [
        cc_info_provider,
        objc_provider,
        new_iosframeworkbundleinfo(),
        new_applebundleinfo(
            archive = None,
            archive_root = None,
            binary = None,
            product_type = ctx.attr.product_type,
            # These arguments are unused - however, put them here incase that
            # somehow changes to make it easier to debug
            bundle_id = "com.bazel_build_rules_ios.unused",
            bundle_name = "bazel_build_rules_ios_unused",
        ),
    ]

    # Add dynamic framework provider if it exists (Bazel < 8)
    if dynamic_framework_provider:
        providers.append(dynamic_framework_provider)
    
    # Add SwiftInfo if there are Swift dependencies
    if swift_infos:
        # For now, just pass through the first SwiftInfo if it exists
        # Proper merging of SwiftInfo is complex and would require swift_common.merge_swift_info
        if len(swift_infos) > 0:
            providers.append(swift_infos[0])
    
    embed_info_provider = embeddable_info.merge_providers(apple_embeddable_infos)
    if embed_info_provider:
        providers.append(embed_info_provider)

    if len(resource_providers) > 0:
        resource_provider = resources.merge_providers(
            default_owner = str(ctx.label),
            providers = resource_providers,
        )
        providers.append(resource_provider)

    # Just to populate the extension safety provider from `rules_apple`.
    partial_output = partial.call(
        partials.extension_safe_validation_partial(
            is_extension_safe = ctx.attr.extension_safe,
            rule_label = ctx.label,
            targets_to_validate = dynamic_frameworks,
        ),
    )

    return providers + partial_output.providers

framework_middleman = rule(
    implementation = _framework_middleman,
    toolchains = use_cpp_toolchain(),
    fragments = ["cpp"],
    attrs = {
        "framework_deps": attr.label_list(
            cfg = transition_support.apple_platform_split_transition,
            mandatory = True,
            doc =
                """Deps that may contain frameworks
""",
        ),
        "extension_safe": attr.bool(
            default = False,
            doc = """Internal - allow rules_apple to populate extension safe provider
""",
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
        "product_type": attr.string(
            mandatory = False,
            default = apple_product_type.framework,
            doc =
                """Internal - The product type of the framework
""",
        ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
            doc = "Needed to allow this rule to have an incoming edge configuration transition.",
        ),
        "_cc_toolchain": attr.label(
            providers = [cc_common.CcToolchainInfo],
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
            doc = """\
The C++ toolchain from which linking flags and other tools needed by the Swift
toolchain (such as `clang`) will be retrieved.
""",
        ),
    },
    doc = """
        This is a volatile internal rule to make frameworks work with
        rules_apples bundling logic

        Longer term, we will likely get rid of this and call partial like
        apple_framework directly so consider it an implementation detail
        """,
)

def _dedupe_key(key, avoid_libraries, objc_provider_fields, check_name = False):
    updated_library = []
    exisiting_library = objc_provider_fields.get(key, depset([]))
    for f in exisiting_library.to_list():
        check_key = (f.basename if check_name else f)
        if check_key in avoid_libraries:
            continue
        updated_library.append(f)
    objc_provider_fields[key] = depset(updated_library)

def _get_lib_name(name):
    """return a lib name for a name dropping prefix/suffix"""
    if name.startswith("lib"):
        name = name[3:]
    if name.endswith(".dylib"):
        name = name[:-6]
    elif name.endswith(".so"):
        name = name[:-3]
    return name

def _dep_middleman(ctx):
    objc_providers = []
    cc_providers = []
    swift_infos = []
    avoid_libraries = {}

    def _collect_providers(lib_dep):
        if apple_common.Objc in lib_dep:
            objc_providers.append(lib_dep[apple_common.Objc])
        if CcInfo in lib_dep:
            cc_providers.append(lib_dep[CcInfo])
        if SwiftInfo in lib_dep:
            swift_infos.append(lib_dep[SwiftInfo])
            # Ensure Swift's CcInfo is also collected
            if CcInfo in lib_dep and lib_dep[CcInfo] not in cc_providers:
                cc_providers.append(lib_dep[CcInfo])

    def _process_avoid_deps(avoid_dep_libs):
        for dep in avoid_dep_libs:
            if apple_common.Objc in dep:
                objc_provider = dep[apple_common.Objc]
                if hasattr(objc_provider, "library"):
                    for lib in objc_provider.library.to_list():
                        avoid_libraries[lib] = True
                if hasattr(objc_provider, "force_load_library"):
                    for lib in objc_provider.force_load_library.to_list():
                        avoid_libraries[lib] = True
                if hasattr(objc_provider, "imported_library"):
                    for lib in objc_provider.imported_library.to_list():
                        avoid_libraries[lib.basename] = True
                if hasattr(objc_provider, "static_framework_file"):
                    for lib in objc_provider.static_framework_file.to_list():
                        avoid_libraries[lib.basename] = True
            if CcInfo in dep:
                for linker_input in dep[CcInfo].linking_context.linker_inputs.to_list():
                    for library_to_link in linker_input.libraries:
                        if library_to_link.static_library:
                            avoid_libraries[library_to_link.static_library] = True

    for dep in ctx.attr.deps:
        _collect_providers(dep)

        # Loop AvoidDepsInfo here as well
        if AvoidDepsInfo in dep:
            _process_avoid_deps(dep[AvoidDepsInfo].libraries)
            for lib_dep in dep[AvoidDepsInfo].libraries:
                _collect_providers(lib_dep)

    # Construct & merge the ObjcProvider, the linking information is only used in Bazel <= 6
    objc_provider_fields = objc_provider_utils.merge_objc_providers_dict(providers = objc_providers, merge_keys = [
        "force_load_library",
        "imported_library",
        "library",
        "link_inputs",
        "linkopt",
        "sdk_dylib",
        "sdk_framework",
        "source",
        "static_framework_file",
        "weak_sdk_framework",
    ])

    # Ensure to strip out static link inputs
    if "library" in objc_provider_fields:
        _dedupe_key("library", avoid_libraries, objc_provider_fields)
    if "force_load_library" in objc_provider_fields:
        _dedupe_key("force_load_library", avoid_libraries, objc_provider_fields)
    if "imported_library" in objc_provider_fields:
        _dedupe_key("imported_library", avoid_libraries, objc_provider_fields, check_name = True)
    if "static_framework_file" in objc_provider_fields:
        _dedupe_key("static_framework_file", avoid_libraries, objc_provider_fields, check_name = True)

    if "sdk_dylib" in objc_provider_fields:
        # Put sdk_dylib at _end_ of the linker invocation. Apple's linkers have
        # problems when SDK dylibs are first in the list, starting with Bazel
        # 6.0 this is backwards by default
        objc_provider_fields["linkopt"] = depset(
            [],
            transitive = [
                objc_provider_fields.get("linkopt", depset([])),
                depset(["-l" + _get_lib_name(lib) for lib in objc_provider_fields.pop("sdk_dylib").to_list()]),
            ],
        )

    objc_provider = apple_common.new_objc_provider(**objc_provider_fields)

    # Construct the CcInfo provider, the linking information is used in Bazel >= 7.
    cc_info_provider = cc_common.merge_cc_infos(cc_infos = cc_providers)
    
    # Bazel 8 compatibility: Ensure all libraries from ObjcInfo are in CcInfo
    # Collect libraries that might not be in CcInfo yet
    all_libraries = []
    for key in ["library", "force_load_library", "imported_library", "static_framework_file"]:
        if key in objc_provider_fields:
            libs = objc_provider_fields[key].to_list()
            for lib in libs:
                # Only add files, not basenames
                if hasattr(lib, "path"):
                    all_libraries.append(lib)
    
    # Add any missing libraries to CcInfo
    if all_libraries:
        cc_toolchain = find_cpp_toolchain(ctx)
        cc_features = cc_common.configure_features(
            ctx = ctx,
            cc_toolchain = cc_toolchain,
            requested_features = ctx.features,
            unsupported_features = ctx.disabled_features,
        )
        
        libraries_to_link = []
        for lib in all_libraries:
            if lib.path.endswith(".a") or lib.path.endswith(".lo"):
                libraries_to_link.append(
                    cc_common.create_library_to_link(
                        actions = ctx.actions,
                        cc_toolchain = cc_toolchain,
                        feature_configuration = cc_features,
                        static_library = lib,
                        alwayslink = lib.path.endswith(".lo"),
                    )
                )
        
        if libraries_to_link:
            additional_cc_info = CcInfo(
                linking_context = cc_common.create_linking_context(
                    linker_inputs = depset([
                        cc_common.create_linker_input(
                            owner = ctx.label,
                            libraries = depset(libraries_to_link),
                        ),
                    ]),
                ),
            )
            cc_info_provider = cc_common.merge_cc_infos(
                direct_cc_infos = [additional_cc_info],
                cc_infos = [cc_info_provider],
            )

    providers = [
        cc_info_provider,
        objc_provider,
    ]
    
    # Add SwiftInfo if there are Swift dependencies
    if swift_infos and len(swift_infos) > 0:
        # Pass through the first SwiftInfo (simplified - may need proper merging)
        providers.append(swift_infos[0])
    
    return providers

dep_middleman = rule(
    implementation = _dep_middleman,
    toolchains = use_cpp_toolchain(),
    attrs = {
        "deps": attr.label_list(
            cfg = transition_support.apple_platform_split_transition,
            mandatory = True,
            doc =
                """Deps that may contain frameworks
""",
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
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
            doc = "Needed to allow this rule to have an incoming edge configuration transition.",
        ),
    },
    doc = """
        This is a volatile internal rule to make frameworks work with
        rules_apples bundling logic

        Longer term, we will likely get rid of this and call partial like
        apple_framework directly so consider it an implementation detail
        """,
)
