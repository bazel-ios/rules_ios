def _add_to_dict_if_present(dict, key, value):
    if value:
        dict[key] = value

objc_merge_keys = [
    "sdk_dylib",
    "sdk_framework",
    "weak_sdk_framework",
    "imported_library",
    "force_load_library",
    "source",
    "link_inputs",
    "linkopt",
    "library",
]

def _merge_objc_providers_dict(providers, transitive = [], merge_keys = objc_merge_keys):
    """
    This makes it a bit eaiser to customize / ovverride these where necessary
    """
    fields = {
        "providers": transitive,
    }
    for key in merge_keys:
        # In Bazel 8+, linking fields are not available in ObjcInfo (migrated to CcInfo)
        # but can still be passed to apple_common.new_objc_provider()
        # Only try to merge fields that actually exist in the providers
        transitive_sets = []
        for provider in providers:
            if hasattr(provider, key):
                transitive_sets.append(getattr(provider, key))
        if transitive_sets:
            set = depset(
                direct = [],
                transitive = transitive_sets,
            )
            _add_to_dict_if_present(fields, key, set)
    return fields

def _merge_objc_providers(providers, transitive = []):
    objc_provider_fields = objc_provider_utils.merge_objc_providers_dict(
        providers = providers,
        transitive = transitive,
    )
    return apple_common.new_objc_provider(**objc_provider_fields)

def _merge_dynamic_framework_providers(dynamic_framework_providers):
    # Note: AppleDynamicFramework only exists in Bazel 7 and earlier
    # Merge all dynamic framework providers into a single struct
    if len(dynamic_framework_providers) == 0:
        return struct(
            framework_dirs = depset([]),
            framework_files = depset([]),
            objc = apple_common.new_objc_provider(),
        )

    framework_dirs = [provider.framework_dirs for provider in dynamic_framework_providers]
    framework_files = [provider.framework_files for provider in dynamic_framework_providers]
    objc_providers = [provider.objc for provider in dynamic_framework_providers]

    return struct(
        framework_dirs = depset(transitive = framework_dirs),
        framework_files = depset(transitive = framework_files),
        objc = apple_common.new_objc_provider(providers = objc_providers),
    )

objc_provider_utils = struct(
    merge_objc_providers_dict = _merge_objc_providers_dict,
    merge_objc_providers = _merge_objc_providers,
    merge_dynamic_framework_providers = _merge_dynamic_framework_providers,
    add_to_dict_if_present = _add_to_dict_if_present,
)
