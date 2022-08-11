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

def _merge_objc_providers(providers, transitive = [], merge_keys = objc_merge_keys):
    objc_provider_fields = objc_provider_utils.merge_objc_providers_dict(
        providers = providers,
        transitive = transitive,
    )
    return apple_common.new_objc_provider(**objc_provider_fields)

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

def _merge_cc_info_providers(ctx, cc_info_providers):
    fields = {}
    merge_keys = [
        "headers",
        #"framework_files",
    ]
    for key in merge_keys:
        set = depset(
            direct = [],
            # Note:  we may want to merge this with the below inputs?
            transitive = [getattr(dep.compilation_context, key) for dep in cc_info_providers],
        )
        _add_to_dict_if_present(fields, key, set)

    # We don't use this on Bazel 4-5 for now
    linking_context = cc_common.create_linking_context(linker_inputs = depset())
    compilation_context = cc_common.create_compilation_context(**fields)
    return CcInfo(compilation_context = compilation_context, linking_context = linking_context) 


objc_provider_utils = struct(
    merge_objc_providers_dict = _merge_objc_providers_dict,
    merge_objc_providers = _merge_objc_providers,
    merge_cc_info_providers = _merge_cc_info_providers,
    merge_dynamic_framework_providers = _merge_dynamic_framework_providers,
    add_to_dict_if_present = _add_to_dict_if_present,
)
