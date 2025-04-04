load("@build_bazel_rules_apple//apple:ios.bzl", rules_apple_ios_extension = "ios_extension")
load("//rules:plists.bzl", "process_infoplists")
load("//rules/internal:framework_middleman.bzl", "dep_middleman", "framework_middleman")

def ios_extension(
        name,
        families = ["iphone", "ipad"],
        infoplists = [],
        infoplists_by_build_setting = {},
        xcconfig = {},
        xcconfig_by_build_setting = {},
        **kwargs):
    """
    Builds and packages an iOS extension.

    The docs for ios_extension are at rules_apple
    https://github.com/bazelbuild/rules_apple/blob/master/doc/rules-ios.md#ios_extension

    Perhaps we can just remove this wrapper longer term.

    Args:
        name: The name of the iOS extension.
        families: A list of iOS device families the target supports.
        infoplists: A list of Info.plist files to be merged into the extension.
        infoplists_by_build_setting: A dictionary of infoplists grouped by bazel build setting.

                                     Each value is applied if the respective bazel build setting
                                     is resolved during the analysis phase.

                                     If '//conditions:default' is not set the value in 'infoplists'
                                     is set as default.
        xcconfig: A dictionary of xcconfigs to be applied to the extension by default.
        xcconfig_by_build_setting: A dictionary of xcconfigs grouped by bazel build setting.

                                   Each value is applied if the respective bazel build setting
                                   is resolved during the analysis phase.

                                   If '//conditions:default' is not set the value in 'xcconfig'
                                   is set as default.
        **kwargs: Arguments passed to the ios_extension rule as appropriate.
    """

    deps = kwargs.pop("deps", [])
    frameworks = kwargs.pop("frameworks", [])
    testonly = kwargs.pop("testonly", False)

    # Setup framework middlemen - need to process deps and libs
    fw_name = name + ".framework_middleman"
    framework_middleman(
        name = fw_name,
        extension_safe = True,
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
    deps = [dep_name]

    processed_infoplists = process_infoplists(
        name = name,
        infoplists = infoplists,
        infoplists_by_build_setting = infoplists_by_build_setting,
        xcconfig = xcconfig,
        xcconfig_by_build_setting = xcconfig_by_build_setting,
    )

    rules_apple_ios_extension(
        name = name,
        deps = deps,
        families = families,
        frameworks = frameworks,
        infoplists = select(processed_infoplists),
        testonly = testonly,
        **kwargs
    )
