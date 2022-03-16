def _add_to_dict_if_present(dict, key, value):
    if value:
        dict[key] = value

def _merge_objc_providers(providers, transitive = [], merge_keys = [
    "sdk_dylib",
    "sdk_framework",
    "weak_sdk_framework",
    "imported_library",
    "force_load_library",
    "source",
    "link_inputs",
    "linkopt",
    "library",
]):
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

def _merge_dynamic_framework_providers(ctx, dynamic_framework_providers):
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

    return apple_common.new_dynamic_framework_provider(**fields)

objc_provider_utils = struct(
    merge_objc_providers = _merge_objc_providers,
    merge_dynamic_framework_providers = _merge_dynamic_framework_providers,
    add_to_dict_if_present = _add_to_dict_if_present,
)
