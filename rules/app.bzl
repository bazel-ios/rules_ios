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
    "bundle_id",
    "bundle_name",
    "infoplists",
    "env",
    "executable_name",
    "minimum_os_version",
    "test_host",
    "families",
    "entitlements",
    "entitlements_validation",
    "extensions",
    "visibility",
    "launch_storyboard",
    "provisioning_profile",
    "resources",
    "app_icons",
    "tags",
    "strings",
    "alternate_icons",
    "settings_bundle",
    "minimum_deployment_os_version",
    "ipa_post_processor",
    "include_symbols_in_bundle",
    "frameworks",
    "version",
    "app_clips",
]

def ios_application(name, apple_library = apple_library, infoplists_by_build_setting = {}, **kwargs):
    """
    Builds and packages an iOS application.

    Args:
        name: The name of the iOS application.
        apple_library: The macro used to package sources into a library.
        infoplists_by_build_setting: A dictionary of infoplists grouped by bazel build setting.

                                     Each value is applied if the respective bazel build setting
                                     is resolved during the analysis phase.

                                     If '//conditions:default' is not set the value in 'infoplists'
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
    application_kwargs["families"] = application_kwargs.pop("families", ["iphone", "ipad"])

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
        infoplists = application_kwargs.pop("infoplists", []),
        infoplists_by_build_setting = infoplists_by_build_setting,
        xcconfig = kwargs.get("xcconfig", {}),
        xcconfig_by_build_setting = kwargs.get("xcconfig_by_build_setting", {}),
    )

    rules_apple_ios_application(
        name = name,
        deps = deps,
        frameworks = frameworks,
        output_discriminator = None,
        infoplists = select(processed_infoplists),
        testonly = testonly,
        **application_kwargs
    )
