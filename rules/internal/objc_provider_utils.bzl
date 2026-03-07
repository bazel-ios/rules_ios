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
        provider_values = []
        for provider in providers:
            # Check if the provider has this attribute (Bazel 8 compatibility)
            if hasattr(provider, key):
                provider_values.append(getattr(provider, key))
        if provider_values:
            set = depset(
                direct = [],
                # Note:  we may want to merge this with the below inputs?
                transitive = provider_values,
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
    # Bazel 8 compatibility: Check if new_dynamic_framework_provider exists
    if not hasattr(apple_common, "new_dynamic_framework_provider"):
        # In Bazel 8, create a struct to carry framework information
        # This will be used to pass framework files through the build
        framework_files = []
        framework_dirs = []
        
        for dep in dynamic_framework_providers:
            if hasattr(dep, "framework_files"):
                framework_files.extend(dep.framework_files.to_list())
            if hasattr(dep, "framework_dirs"):
                framework_dirs.extend(dep.framework_dirs.to_list())
        
        return struct(
            framework_files = depset(framework_files),
            framework_dirs = depset(framework_dirs),
            objc = apple_common.new_objc_provider(),
            cc_info = CcInfo(),
        )
        
    fields = {}
    merge_keys = [
        "framework_dirs",
        "framework_files",
    ]
    for key in merge_keys:
        provider_values = []
        for dep in dynamic_framework_providers:
            if hasattr(dep, key):
                provider_values.append(getattr(dep, key))
        if provider_values:
            set = depset(
                direct = [],
                # Note:  we may want to merge this with the below inputs?
                transitive = provider_values,
            )
            _add_to_dict_if_present(fields, key, set)

    fields["objc"] = apple_common.new_objc_provider()
    fields["cc_info"] = CcInfo()

    return apple_common.new_dynamic_framework_provider(**fields)

objc_provider_utils = struct(
    merge_objc_providers_dict = _merge_objc_providers_dict,
    merge_objc_providers = _merge_objc_providers,
    merge_dynamic_framework_providers = _merge_dynamic_framework_providers,
    add_to_dict_if_present = _add_to_dict_if_present,
)
