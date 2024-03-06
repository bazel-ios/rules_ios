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

def _merge_dynamic_framework_providers(dynamic_framework_providers, supports_cc_info_in_dynamic_framework_provider):
    fields = {}
    merge_keys = [
        "framework_dirs",
        "framework_files",
    ]
    for key in merge_keys:
        set = depset(
            direct = [],
            # Note:  we may want to merge this with the below inputs?
            transitive = [getattr(dep, key) for dep in dynamic_framework_providers],
        )
        _add_to_dict_if_present(fields, key, set)

    fields["objc"] = apple_common.new_objc_provider()

    if not supports_cc_info_in_dynamic_framework_provider:
        fields.pop("cc_info", None)
    elif "cc_info" not in fields:
        fields["cc_info"] = CcInfo()

    return apple_common.new_dynamic_framework_provider(**fields)

objc_provider_utils = struct(
    merge_objc_providers_dict = _merge_objc_providers_dict,
    merge_objc_providers = _merge_objc_providers,
    merge_dynamic_framework_providers = _merge_dynamic_framework_providers,
    add_to_dict_if_present = _add_to_dict_if_present,
)
