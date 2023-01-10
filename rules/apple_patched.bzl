"""This file contains drop-in replacements for rules in the rules_apple repository"""

load(
    "@build_bazel_rules_apple//apple:apple.bzl",
    apple_dynamic_framework_import_original = "apple_dynamic_framework_import",
    apple_static_framework_import_original = "apple_static_framework_import",
)
load(
    "@build_bazel_rules_apple//apple/internal:framework_import_support.bzl",
    "framework_import_support",
)
load("@build_bazel_rules_apple//apple:providers.bzl", "AppleFrameworkImportInfo")
load("@build_bazel_rules_swift//swift/internal:providers.bzl", "SwiftUsageInfo")
load("//rules/framework:vfs_overlay.bzl", "make_vfsoverlay")
load("//rules:providers.bzl", "FrameworkInfo")
load("//rules:features.bzl", "feature_names")

def apple_dynamic_framework_import(name, **kwargs):
    """Patches an apple_dynamic_framework_import target based on the problems reported in https://github.com/bazel-ios/rules_ios/issues/55

    Args: same as the ones of apple_dynamic_framework_import
    """

    visibility = kwargs.pop("visibility", None)
    tags = kwargs.pop("tags", [])

    legacy_target_label = "_" + name
    apple_dynamic_framework_import_original(
        name = legacy_target_label,
        tags = tags + ["manual"],
        **kwargs
    )

    _apple_framework_import_modulemap(
        name = name,
        legacy_target = legacy_target_label,
        framework_imports = kwargs.get("framework_imports", []),
        visibility = visibility,
        tags = tags,
    )

def apple_static_framework_import(name, **kwargs):
    """Patches an apple_static_framework_import target based on the problems reported in https://github.com/bazel-ios/rules_ios/issues/55

    Args: same as the ones of apple_static_framework_import
    """

    visibility = kwargs.pop("visibility", None)
    tags = kwargs.pop("tags", [])

    legacy_target_label = "_" + name
    apple_static_framework_import_original(
        name = legacy_target_label,
        tags = tags + ["manual"],
        **kwargs
    )

    _apple_framework_import_modulemap(
        name = name,
        legacy_target = legacy_target_label,
        framework_imports = kwargs.get("framework_imports", []),
        visibility = visibility,
        tags = tags,
    )

def _find_imported_framework_name(outputs):
    for output in outputs:
        if not ".framework" in output:
            continue
        prefix = output.split(".framework/")[0]
        fw_name = prefix.split("/")[-1]
        return fw_name
    return None

def _get_framework_info_providers(ctx, old_cc_info, modulemap_list):
    virtualize_frameworks = feature_names.virtualize_frameworks in ctx.features
    if not virtualize_frameworks:
        return []

    hdrs_list = old_cc_info.compilation_context.headers.to_list()
    hdrs = [h.path for h in hdrs_list]

    imported_framework_name = _find_imported_framework_name(hdrs)

    # If the user is using an apple framework import without any headers then
    # don't enter this in the virtual framework for now.
    if not imported_framework_name:
        return []

    vfs = make_vfsoverlay(
        ctx,
        hdrs = hdrs_list,
        module_map = modulemap_list,
        # Consider aligning this code with the way that frameworks are
        # imported from rules/library.bzl. There are effectivly 2 different ways
        # that frameworks are being imported.  Otherwise, a test case for
        # swiftmodules ensuring it extracts from the provider. The swiftmodules
        # for this case should be loaded into the VFS
        swiftmodules = [],
        private_hdrs = [],
        has_swift = False,
        framework_name = imported_framework_name,
        extra_search_paths = imported_framework_name,
    )
    framework_info = FrameworkInfo(
        vfsoverlay_infos = [vfs.vfs_info],
        headers = hdrs_list,
        private_headers = [],
        modulemap = modulemap_list,
        swiftmodule = [],
        swiftdoc = [],
    )
    return [framework_info]

def _apple_framework_import_modulemap_impl(ctx):
    legacy_target = ctx.attr.legacy_target
    objc_provider = legacy_target[apple_common.Objc]
    old_cc_info = legacy_target[CcInfo]

    # Pull the `.modulemap` files out of the `framework_imports` since the
    # propagation of this was removed from `ObjcProvider`.
    framework_imports_by_category = framework_import_support.classify_file_imports(
        ctx.var,
        ctx.files.framework_imports,
    )

    # Merge providers
    new_cc_info = cc_common.merge_cc_infos(
        cc_infos = [
            old_cc_info,
            CcInfo(compilation_context = cc_common.create_compilation_context(headers = depset(framework_imports_by_category.module_map_imports))),
        ],
    )

    additional_providers = _get_framework_info_providers(ctx, old_cc_info, framework_imports_by_category.module_map_imports)

    # Seems that there is no way to iterate on the existing providers, so what is possible instead
    # is to list here the keys to all of them (you can see the keys for the existing providers of a
    # target by just printing the target)
    # For more information refer to https://groups.google.com/forum/#!topic/bazel-discuss/4KkflTjmUyk
    other_provider_keys = [AppleFrameworkImportInfo, SwiftUsageInfo, apple_common.AppleDynamicFramework, OutputGroupInfo, DefaultInfo]
    return additional_providers + [objc_provider, new_cc_info] + \
           [legacy_target[provider_key] for provider_key in other_provider_keys if provider_key in legacy_target]

_apple_framework_import_modulemap = rule(
    implementation = _apple_framework_import_modulemap_impl,
    fragments = ["apple"],
    attrs = {
        "legacy_target": attr.label(
            mandatory = True,
            doc = "The legacy target to patch",
        ),
        "framework_imports": attr.label_list(
            allow_files = True,
            doc = "The list of files under a `.framework` directory for `legacy_target`.",
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
            doc = """\
The C++ toolchain from which linking flags and other tools needed by the Swift
toolchain (such as `clang`) will be retrieved.
""",
        ),
    },
    doc = "Patches the associated legacy_target",
)
