load("@build_bazel_rules_apple//apple:ios.bzl", rules_apple_ios_app_clip = "ios_app_clip")
load("//rules:plists.bzl", "process_infoplists")
load("//rules:force_load_direct_deps.bzl", "force_load_direct_deps")
load("//rules/internal:framework_middleman.bzl", "dep_middleman", "framework_middleman")

def ios_app_clip(
        name,
        infoplists = [],
        infoplists_by_build_setting = {},
        xcconfig = {},
        xcconfig_by_build_setting = {},
        **kwargs):
    """
    Builds and packages an iOS App Clip.

    The docs for app_clip are at rules_apple
    https://github.com/bazelbuild/rules_apple/blob/master/doc/rules-ios.md#ios_app_clip

    Args:
        name: The name of the iOS app clip.
        infoplists: A list of Info.plist files to be merged into the app clip.
        infoplists_by_build_setting: A dictionary of infoplists grouped by bazel build setting.

                                     Each value is applied if the respective bazel build setting
                                     is resolved during the analysis phase.

                                     If '//conditions:default' is not set the value in 'infoplists'
                                     is set as default.
        xcconfig: A dictionary of xcconfigs to be applied to the app clip by default.
        xcconfig_by_build_setting: A dictionary of xcconfigs grouped by bazel build setting.

                                   Each value is applied if the respective bazel build setting
                                   is resolved during the analysis phase.

                                   If '//conditions:default' is not set the value in 'xcconfig'
                                   is set as default.
        **kwargs: Arguments passed to the ios_app_clip rule as appropriate.
    """

    deps = kwargs.pop("deps", [])
    frameworks = kwargs.pop("frameworks", [])
    testonly = kwargs.pop("testonly", False)

    # Setup force loading here - need to process deps and libs
    force_load_name = name + ".force_load_direct_deps"
    force_load_direct_deps(
        name = force_load_name,
        deps = deps,
        tags = ["manual"],
        testonly = testonly,
    )

    # Setup framework middlemen - need to process deps and libs
    fw_name = name + ".framework_middleman"
    framework_middleman(
        name = fw_name,
        framework_deps = deps,
        tags = ["manual"],
        testonly = testonly,
    )
    frameworks = [fw_name] + frameworks

    dep_name = name + ".dep_middleman"
    dep_middleman(
        name = dep_name,
        deps = deps,
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

    rules_apple_ios_app_clip(
        name = name,
        deps = deps,
        frameworks = frameworks,
        output_discriminator = None,
        infoplists = select(processed_infoplists),
        testonly = testonly,
        **kwargs
    )
