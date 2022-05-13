"""Common helper macros that could be used in different BUILD and/or extension files"""

def bundle_identifier_for_bundle(bundle_name):
    return "com.cocoapods." + bundle_name
