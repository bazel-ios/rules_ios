load(
    "//rules/library:xcconfig.bzl",
    _build_setting_name = "build_setting_name",
    _copts_by_build_setting_with_defaults = "copts_by_build_setting_with_defaults",
    _merge_xcconfigs = "merge_xcconfigs",
)

build_setting_name = _build_setting_name
copts_by_build_setting_with_defaults = _copts_by_build_setting_with_defaults
merge_xcconfigs = _merge_xcconfigs
