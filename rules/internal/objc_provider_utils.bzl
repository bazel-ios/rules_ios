def _add_to_dict_if_present(dict, key, value):
    if value:
        dict[key] = value

objc_merge_keys = [
    "source",
]

def _merge_objc_providers_dict(providers, transitive = [], merge_keys = objc_merge_keys):
    """
    This makes it a bit eaiser to customize / ovverride these where necessary
    """
    fields = {
        "providers": transitive,
    }
    for key in merge_keys:
        set = depset(
            direct = [],
            # Note:  we may want to merge this with the below inputs?
            transitive = [getattr(provider, key) for provider in providers],
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
    # AppleDynamicFramework provider removed in Bazel 8 / rules_apple 4.x
    # Return a mock struct with empty framework_files for backwards compatibility
    # This was only used for Bazel <= 6
    if len(dynamic_framework_providers) > 0:
        fail("AppleDynamicFramework provider no longer exists in Bazel 8")

    return struct(
        framework_dirs = depset([]),
        framework_files = depset([]),
        objc = apple_common.new_objc_provider(),
    )

objc_provider_utils = struct(
    merge_objc_providers_dict = _merge_objc_providers_dict,
    merge_objc_providers = _merge_objc_providers,
    merge_dynamic_framework_providers = _merge_dynamic_framework_providers,
    add_to_dict_if_present = _add_to_dict_if_present,
)
