load(
    "@build_bazel_rules_apple//apple:providers.bzl",
    "AppleBundleInfo",
    "AppleResourceInfo",
    "IosFrameworkBundleInfo",
)
load(
    "@build_bazel_rules_apple//apple/internal:resources.bzl",
    "resources",
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

def _framework_middleman(ctx):
    resource_providers = []
    objc_providers = []
    dynamic_framework_providers = []
    apple_embeddable_infos = []
    cc_providers = []

    def _collect_providers(lib_dep):
        if AppleEmbeddableInfo in lib_dep:
            apple_embeddable_infos.append(lib_dep[AppleEmbeddableInfo])
        if IosFrameworkBundleInfo in lib_dep:
            if CcInfo in lib_dep:
                cc_providers.append(lib_dep[CcInfo])
        if apple_common.Objc in lib_dep:
            objc_providers.append(lib_dep[apple_common.Objc])
        if apple_common.AppleDynamicFramework in lib_dep:
            dynamic_framework_providers.append(lib_dep[apple_common.AppleDynamicFramework])
        if AppleResourceInfo in lib_dep:
            resource_providers.append(lib_dep[AppleResourceInfo])

    for dep in ctx.attr.framework_deps:
        _collect_providers(dep)

        # Loop AvoidDepsInfo here as well
        if AvoidDepsInfo in dep:
            for lib_dep in dep[AvoidDepsInfo].libraries:
                _collect_providers(lib_dep)

    objc_provider_fields = objc_provider_utils.merge_objc_providers_dict(providers = objc_providers, merge_keys = [
        "sdk_dylib",
        "sdk_framework",
        "weak_sdk_framework",
        "force_load_library",
        "source",
        "link_inputs",
        "linkopt",
        "library",
        "imported_library",
        "dynamic_framework_file",
        "static_framework_file",
    ])

    # Adds the frameworks to the linker command
    dynamic_framework_provider = objc_provider_utils.merge_dynamic_framework_providers(ctx, dynamic_framework_providers)
    linkopt = []
    for f in dynamic_framework_provider.framework_files.to_list():
        linkopt.append("\"-F" + "/".join(f.path.split("/")[:-2]) + "\"")

        # This should take the suffix here - it seemes like that is not working
        fw_name = f.basename.replace(".framework", "")
        linkopt.append("-Wl,-framework," + fw_name)

    objc_provider_fields["linkopt"] = depset(
        linkopt,
        transitive = [objc_provider_fields.get("linkopt", depset([]))],
    )
    objc_provider_fields["link_inputs"] = depset(
        transitive = [getattr(dynamic_framework_provider, "framework_files")] + [objc_provider_fields.get("link_inputs", depset([]))],
    )
    objc_provider = apple_common.new_objc_provider(**objc_provider_fields)

    cc_info_provider = cc_common.merge_cc_infos(direct_cc_infos = [], cc_infos = cc_providers)
    if len(resource_providers) > 0:
        resource_provider = resources.merge_providers(
            default_owner = str(ctx.label),
            providers = resource_providers,
        )
    else:
        resource_provider = AppleResourceInfo(unowned_resources = depset([]), owners = depset([]))
    embed_info_provider = embeddable_info.merge_providers(apple_embeddable_infos)
    return [
        dynamic_framework_provider,
        cc_info_provider,
        objc_provider,
        resource_provider,
        IosFrameworkBundleInfo(),
        AppleBundleInfo(
            archive = None,
            archive_root = None,

            # These arguments are unused - however, put them here incase that
            # somehow changes to make it easier to debug
            bundle_id = "com.bazel_build_rules_ios.unused",
            bundle_name = "bazel_build_rules_ios_unused",
        ),
    ] + ([embed_info_provider] if embed_info_provider else [])

framework_middleman = rule(
    implementation = _framework_middleman,
    attrs = {
        "framework_deps": attr.label_list(
            cfg = apple_common.multi_arch_split,
            mandatory = True,
            doc =
                """Deps of the deps
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
    },
    doc = """
        This is a volatile internal rule to make frameworks work with
        rules_apples bundling logic

        Longer term, we will likely get rid of this and call partial like
        apple_framework directly so consider it an implementation detail
        """,
)
