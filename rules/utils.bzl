"""Common helper macros that could be used in different BUILD and/or extension files"""

def bundle_identifier_for_bundle(bundle_name):
    return "com.cocoapods." + bundle_name

# This is a proxy for being on bazel 7.x.
is_bazel_7 = not hasattr(apple_common, "apple_crosstool_transition")
