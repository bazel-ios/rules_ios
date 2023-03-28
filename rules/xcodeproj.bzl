""" Xcode Project Generation Logic """

load("//rules:legacy_xcodeproj.bzl", legacy_xcodeproj = "xcodeproj")
load("@xchammer//:BazelExtensions/xcodeproject.bzl", xchammer_xcodeproj = "xcode_project")
load("@rules_xcodeproj//xcodeproj:defs.bzl", rules_xcodeproj = "xcodeproj")

_GENERATORS = [
    "legacy",
    "rules_xcodeproj",
    "xchammer",
]

# https://github.com/bazel-ios/rules_ios/blob/master/rules/legacy_xcodeproj.bzl
_LEGACY_XCODEPROJ_KWARGS = [
    "configs",
    "target_settings_by_config",
    "deps",
    "include_transitive_targets",
    "project_name",
    "output_path",
    "bazel_path",
    "scheme_existing_envvar_overrides",
    "project_attributes_overrides",
    "project_options_overrides",
    "additional_scheme_infos",
    "generate_schemes_for_product_types",
    "output_processor",
    "index_import",
    "clang_stub",
    "ld_stub",
    "swiftc_stub",
    "print_json_leaf_nodes",
    "installer",
    "build_wrapper",
    "additional_files",
    "additional_prebuild_script",
    "additional_bazel_build_options",
    "additional_pre_actions",
    "additional_post_actions",
    "provide_build_settings_from_target_for_pre_post_actions",
    "additional_lldb_settings",
    "bazel_execution_log_enabled",
    "bazel_profile_enabled",
    "disable_main_thread_checker",
    "force_x86_sim",
]

# https://github.com/MobileNativeFoundation/rules_xcodeproj/blob/main/xcodeproj/internal/xcodeproj_macro.bzl
_RULES_XCODEPROJ_KWARGS = [
    "adjust_schemes_for_swiftui_previews",
    "archived_bundles_allowed",
    "associated_extra_files",
    "bazel_path",
    "build_mode",
    "config",
    "default_xcode_configuration",
    "extra_files",
    "focused_targets",
    "install_directory",
    "ios_device_cpus",
    "ios_simulator_cpus",
    "minimum_xcode_version",
    "post_build",
    "pre_build",
    "project_name",
    "project_options",
    "scheme_autogeneration_mode",
    "schemes",
    "temporary_directory",
    "top_level_targets",
    "tvos_device_cpus",
    "tvos_simulator_cpus",
    "unfocused_targets",
    "watchos_device_cpus",
    "watchos_simulator_cpus",
    "xcode_configurations",
]

# https://github.com/bazel-ios/xchammer/blob/rules-ios-xchammer/BazelExtensions/xcodeproject.bzl
_XCHAMMER_XCODEPROJ_KWARGS = [
    "targets",
    "bazel",
    "xchammer",
    "project_name",
    "target_config",
    "project_config",
    "bazel_build_service_config",
]

def xcodeproj(
        name,
        generator = "legacy",
        **kwargs):
    """Macro that allows one to use different Xcode generators via the `generator` attribute.

    - Accepted values are ["legacy", "rules_xcodeproj", "xchammer"]
    - valid kwargs only are propagated to the respective generator

    Args:
      name: A unique name for this target
      generator: One of ["legacy", "rules_xcodeproj", "xchammer"], defaults to "legacy"
      **kwargs: Arguments to propagate to the respective generator
    """
    if generator not in _GENERATORS:
        fail("[ERROR] Unsupported generator: {}. Acceptable values: {}".format(generator, _GENERATORS))

    # Making sure this attribute is set to address rules_swift requirement
    # See: https://github.com/bazel-ios/rules_ios/pull/573
    testonly = kwargs.pop("testonly", False)

    if generator == "legacy":
        legacy_xcodeproj_kwargs = {arg: kwargs.pop(arg) for arg in _LEGACY_XCODEPROJ_KWARGS if arg in kwargs}
        legacy_xcodeproj(
            name = name,
            testonly = testonly,
            **legacy_xcodeproj_kwargs
        )
    elif generator == "rules_xcodeproj":
        rules_xcodeproj_kwargs = {arg: kwargs.pop(arg) for arg in _RULES_XCODEPROJ_KWARGS if arg in kwargs}
        rules_xcodeproj(
            name = name,
            testonly = testonly,
            **rules_xcodeproj_kwargs
        )
    elif generator == "xchammer":
        xchammer_xcodeproj_kwargs = {arg: kwargs.pop(arg) for arg in _XCHAMMER_XCODEPROJ_KWARGS if arg in kwargs}
        xchammer_xcodeproj(
            name = name,
            testonly = testonly,
            **xchammer_xcodeproj_kwargs
        )
