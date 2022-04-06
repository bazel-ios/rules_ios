# Used in tests/ios/pod2build to test PodToBUILD integration.

# Source Pod
# TODO: Fix error
#
# /private/var/tmp/_bazel_lpadron/7c5e30dd733c097d91026d4bca2f7997/execroot/build_bazel_rules_ios/tests/ios/pod2build/Sources/App.swift:1:8: error: no such module 'Protobuf'
# import Protobuf
#
new_pod_repository(
    name = "Protobuf",
    generate_module_map = False,
    url = "https://github.com/protocolbuffers/protobuf/archive/v3.6.0.zip",
)

# XCFramework Pod
# TODO: Fix error
#
# Error in fail: Expected only files inside directories named with the extensions ["framework"], but found: [
#   Vendor/AppsFlyerFramework/AppsFlyerLib.xcframework/Info.plist
# ] framework_imports
#
new_pod_repository(
    name = "AppsFlyerFramework",
    url = "https://github.com/AppsFlyerSDK/AppsFlyerFramework/archive/6.5.4.zip",
)
