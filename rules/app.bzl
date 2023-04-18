load("@build_bazel_rules_apple//apple:ios.bzl", rules_apple_ios_application = "ios_application")
load("//rules:library.bzl", "apple_library")
load("//rules:plists.bzl", "process_infoplists")
load("//rules:force_load_direct_deps.bzl", "force_load_direct_deps")
load("//rules/internal:framework_middleman.bzl", "dep_middleman", "framework_middleman")

# We need to try and partition out arguments for obj_library / swift_library
# from ios_application since this creates source file libs internally.
#
# The docs for ios_application are at rules_apple
# https://github.com/bazelbuild/rules_apple/blob/master/doc/rules-ios.md#ios_application
# - Perhaps we can just remove this wrapper longer term.
_IOS_APPLICATION_KWARGS = [
    "additional_linker_inputs",
    "alternate_icons",
    "app_clips",
    "app_icons",
    "bundle_id",
    "bundle_name",
    "entitlements",
    "entitlements_validation",
    "env",
    "executable_name",
    "extensions",
    "frameworks",
    "include_symbols_in_bundle",
    "infoplists",
    "ipa_post_processor",
    "launch_storyboard",
    "linkopts",
    "minimum_deployment_os_version",
    "minimum_os_version",
    "provisioning_profile",
    "resources",
    "settings_bundle",
    "strings",
    "tags",
    "test_host",
    "version",
    "visibility",
]

def ios_application(
        name,
        families = ["iphone", "ipad"],
        apple_library = apple_library,
        infoplists = [],
        infoplists_by_build_setting = {},
        xcconfig = {},
        xcconfig_by_build_setting = {},
        **kwargs):
    """
    Builds and packages an iOS application.

    Args:
        name: The name of the iOS application.
        families: A list of iOS device families the target supports.
        apple_library: The macro used to package sources into a library.
        infoplists: A list of Info.plist files to be merged into the iOS app.
        infoplists_by_build_setting: A dictionary of infoplists grouped by bazel build setting.

                                     Each value is applied if the respective bazel build setting
                                     is resolved during the analysis phase.

                                     If '//conditions:default' is not set the value in 'infoplists'
                                     is set as default.
        xcconfig: A dictionary of xcconfigs to be applied to the iOS app by default.
        xcconfig_by_build_setting: A dictionary of xcconfigs grouped by bazel build setting.

                                   Each value is applied if the respective bazel build setting
                                   is resolved during the analysis phase.

                                   If '//conditions:default' is not set the value in 'xcconfig'
                                   is set as default.
        **kwargs: Arguments passed to the apple_library and ios_application rules as appropriate.
    """

    testonly = kwargs.pop("testonly", False)
    application_kwargs = {arg: kwargs.pop(arg) for arg in _IOS_APPLICATION_KWARGS if arg in kwargs}
    library = apple_library(
        name = name,
        namespace_is_module_name = False,
        platforms = {"ios": application_kwargs.get("minimum_os_version")},
        testonly = testonly,
        **kwargs
    )

    application_kwargs["launch_storyboard"] = application_kwargs.pop("launch_storyboard", library.launch_screen_storyboard_name)

    # Setup force loading here - need to process deps and libs
    force_load_name = name + ".force_load_direct_deps"
    force_load_direct_deps(
        name = force_load_name,
        deps = kwargs.get("deps", []) + library.lib_names,
        tags = ["manual"],
        testonly = testonly,
    )

    # Setup framework middlemen - need to process deps and libs
    fw_name = name + ".framework_middleman"
    framework_middleman(
        name = fw_name,
        framework_deps = kwargs.get("deps", []) + library.lib_names,
        tags = ["manual"],
        testonly = testonly,
    )
    frameworks = [fw_name] + kwargs.pop("frameworks", [])

    dep_name = name + ".dep_middleman"
    dep_middleman(
        name = dep_name,
        deps = kwargs.get("deps", []) + library.lib_names,
        tags = ["manual"],
        testonly = testonly,
    )
    deps = [dep_name] + [force_load_name]

    processed_infoplists = process_infoplists(
        name = name,
        infoplists = infoplists,
        infoplists_by_build_setting = infoplists_by_build_setting,
        xcconfig = xcconfig,
        xcconfig_by_build_setting = xcconfig_by_build_setting,
    )

    rules_apple_ios_application(
        name = name,
        deps = deps,
        frameworks = frameworks,
        families = families,
        output_discriminator = None,
        infoplists = select(processed_infoplists),
        testonly = testonly,
        **application_kwargs
    )
