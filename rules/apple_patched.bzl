"""This file contains drop-in replacements for rules in the rules_apple repository"""

load(
    "@build_bazel_rules_apple//apple:apple.bzl",
    apple_dynamic_framework_import_original = "apple_dynamic_framework_import",
    apple_static_framework_import_original = "apple_static_framework_import",
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

def _get_framework_info_providers(ctx, old_cc_info, old_objc_provider):
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

    modulemap_list = old_objc_provider.module_map.to_list()
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
    old_objc_provider = legacy_target[apple_common.Objc]
    old_cc_info = legacy_target[CcInfo]

    # Merge providers
    objc_provider_fields = {
        "providers": [old_objc_provider],
        # Adding the module_map to the headers.
        # This "hack" is just a way to propagate the module map. swift_rules has a field in its provider
        # called swiftc_inputs where you can pass extra dependencies to the compiler. Unfortunately
        # the objc provider has no such field. The "hack" is to pass the module map as a header so that
        # it makes it to the list of dependencies. Since it doesn't end in .h it gets ignored but it's
        # still propagated as a dependency. This "hack" is based on:
        # a) https://github.com/bazelbuild/rules_apple/blob/313eeb838497e230f01a7367ae4555aaf0cac62e/apple/internal/apple_framework_import.bzl#L98
        # b) https://github.com/bazel-ios/rules_ios/blob/1755c694f8d5cc1ed256bba7ccf122a3fbc4addf/rules/framework.bzl#L247
        "header": old_objc_provider.module_map,
    }
    new_objc_provider = apple_common.new_objc_provider(**objc_provider_fields)
    new_cc_info = cc_common.merge_cc_infos(
        cc_infos = [
            old_cc_info,
            CcInfo(compilation_context = cc_common.create_compilation_context(headers = depset(old_objc_provider.module_map))),
        ],
    )

    additional_providers = _get_framework_info_providers(ctx, old_cc_info, old_objc_provider)

    # Seems that there is no way to iterate on the existing providers, so what is possible instead
    # is to list here the keys to all of them (you can see the keys for the existing providers of a
    # target by just printing the target)
    # For more information refer to https://groups.google.com/forum/#!topic/bazel-discuss/4KkflTjmUyk
    other_provider_keys = [AppleFrameworkImportInfo, SwiftUsageInfo, apple_common.AppleDynamicFramework, OutputGroupInfo, DefaultInfo]
    return additional_providers + [new_objc_provider, new_cc_info] + \
           [legacy_target[provider_key] for provider_key in other_provider_keys if provider_key in legacy_target]

_apple_framework_import_modulemap = rule(
    implementation = _apple_framework_import_modulemap_impl,
    attrs = {
        "legacy_target": attr.label(
            mandatory = True,
            doc = "The legacy target to patch",
        ),
    },
    doc = "Patches the associated legacy_target",
)
