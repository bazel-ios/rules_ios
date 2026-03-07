"""Utilities for detecting and handling Bazel version differences."""

def _parse_bazel_version(bazel_version):
    """Parse Bazel version string into major, minor, patch components.
    
    Args:
        bazel_version: String like "8.0.0" or "7.1.0"
    
    Returns:
        Tuple of (major, minor, patch) as integers
    """
    # Handle development versions like "8.0.0-pre.20240101.1"
    parts = bazel_version.split("-")[0].split(".")
    major = int(parts[0]) if len(parts) > 0 else 0
    minor = int(parts[1]) if len(parts) > 1 else 0
    patch = int(parts[2]) if len(parts) > 2 else 0
    return (major, minor, patch)

def _is_bazel_8_or_higher():
    """Check if running Bazel 8 or higher.
    
    Returns:
        True if Bazel version is 8.0.0 or higher, False otherwise
    """
    if hasattr(native, "bazel_version"):
        major, _, _ = _parse_bazel_version(native.bazel_version)
        return major >= 8
    return False

def _has_apple_dynamic_framework_provider():
    """Check if apple_common.AppleDynamicFramework provider is available.
    
    Returns:
        True if the provider exists, False otherwise (Bazel 8+)
    """
    return hasattr(apple_common, "AppleDynamicFramework")

def _has_objc_provider_field(field_name):
    """Check if a specific ObjcInfo provider field is available.
    
    Args:
        field_name: Name of the field to check
    
    Returns:
        True if the field is available in ObjcInfo
    """
    # In Bazel 8, many ObjcInfo fields were removed
    # Available fields: direct_module_maps, direct_sources, j2objc_library, 
    #                   module_map, source, strict_include, umbrella_header
    removed_in_bazel_8 = [
        "force_load_library",
        "imported_library", 
        "library",
        "link_inputs",
        "linkopt",
        "sdk_dylib",
        "sdk_framework",
        "static_framework_file",
        "weak_sdk_framework",
        "dynamic_framework_file",
    ]
    
    if _is_bazel_8_or_higher() and field_name in removed_in_bazel_8:
        return False
    return True

bazel_version = struct(
    parse = _parse_bazel_version,
    is_bazel_8_or_higher = _is_bazel_8_or_higher,
    has_apple_dynamic_framework_provider = _has_apple_dynamic_framework_provider,
    has_objc_provider_field = _has_objc_provider_field,
)