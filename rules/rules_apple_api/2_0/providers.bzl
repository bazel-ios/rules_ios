load(
    "@build_bazel_rules_apple//apple:providers.bzl",
    _AppleBundleInfo = "AppleBundleInfo",
    _AppleFrameworkImportInfo = "AppleFrameworkImportInfo",
    _AppleResourceBundleInfo = "AppleResourceBundleInfo",
    _AppleResourceInfo = "AppleResourceInfo",
    _IosFrameworkBundleInfo = "IosFrameworkBundleInfo",
)

new_appleresourcebundleinfo = _AppleResourceBundleInfo
new_applebundleinfo = _AppleBundleInfo
new_appleresourceinfo = _AppleResourceInfo
new_iosframeworkbundleinfo = _IosFrameworkBundleInfo
new_appleframeworkimportinfo = _AppleFrameworkImportInfo
