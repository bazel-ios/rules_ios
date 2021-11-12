load("@build_bazel_rules_apple//apple:ios.bzl", rules_apple_ios_ui_test = "ios_ui_test", rules_apple_ios_ui_test_suite = "ios_ui_test_suite", rules_apple_ios_unit_test = "ios_unit_test", rules_apple_ios_unit_test_suite = "ios_unit_test_suite")
load("@bazel_skylib//lib:types.bzl", "types")
load("//rules:library.bzl", "apple_library")
load("//rules:plists.bzl", "info_plists_by_setting")
load("//rules:import_middleman.bzl", "import_middleman")

_IOS_TEST_KWARGS = [
    "bundle_id",
    "infoplists",
    "minimum_os_version",
    "test_host",
    "env",
    "args",
    "size",
    "timeout",
    "visibility",
    "resources",
    "tags",
    "shard_count",
    "flaky",
]

def _ios_test(name, test_rule, test_suite_rule, apple_library, infoplists_by_build_setting = {}, **kwargs):
    """
    Builds and packages iOS Unit/UI Tests.

    Args:
        name: The name of the unit test.
        test_rule: The underlying rules_apple test rule.
        test_suite_rule: The underlying rules_apple test suite rule.
        apple_library: The macro used to package sources into a library.
        infoplists_by_build_setting: A dictionary of infoplists grouped by bazel build setting.

                                     Each value is applied if the respective bazel build setting
                                     is resolved during the analysis phase.

                                     If '//conditions:default' is not set the value in 'infoplists'
                                     is set as default.
        **kwargs: Arguments passed to the apple_library and test_rule rules as appropriate.
    """

    ios_test_kwargs = {arg: kwargs.pop(arg) for arg in _IOS_TEST_KWARGS if arg in kwargs}

    ios_test_kwargs["data"] = kwargs.pop("test_data", [])
    if ios_test_kwargs.get("test_host", None) == True:
        ios_test_kwargs["test_host"] = "@build_bazel_rules_ios//rules/test_host_app:iOS-%s-AppHost" % ios_test_kwargs.get("minimum_os_version")

    if "runner" in kwargs and "runners" in kwargs:
        fail("cannot specify both runner and runners for %s" % name)

    runner = kwargs.pop("runner", kwargs.pop("runners", None))
    rule = test_rule
    if runner:
        if types.is_list(runner):
            ios_test_kwargs["runners"] = runner
            rule = test_suite_rule
        else:
            ios_test_kwargs["runner"] = runner

    library = apple_library(name = name, namespace_is_module_name = False, platforms = {"ios": ios_test_kwargs.get("minimum_os_version")}, **kwargs)

    import_middleman(name = name + ".import_middleman", deps = library.lib_names, tags = ["manual"])
    rule(
        name = name,
        deps = select({
            "@build_bazel_rules_ios//:arm_simulator_use_device_deps": [name + ".import_middleman"],
            "//conditions:default": library.lib_names,
        }),
        infoplists = info_plists_by_setting(name = name, infoplists_by_build_setting = infoplists_by_build_setting, default_infoplists = ios_test_kwargs.pop("infoplists", [])),
        **ios_test_kwargs
    )

def ios_unit_test(name, apple_library = apple_library, **kwargs):
    """
    Builds and packages iOS Unit Tests.

    Args:
        name: The name of the unit test.
        apple_library: The macro used to package sources into a library.
        **kwargs: Arguments passed to the apple_library and ios_unit_test rules as appropriate.
    """
    _ios_test(name, rules_apple_ios_unit_test, rules_apple_ios_unit_test_suite, apple_library, **kwargs)

def ios_ui_test(name, apple_library = apple_library, **kwargs):
    """
    Builds and packages iOS UI Tests.

    Args:
        name: The name of the UI test.
        apple_library: The macro used to package sources into a library.
        **kwargs: Arguments passed to the apple_library and ios_ui_test rules as appropriate.
    """
    if not kwargs.get("test_host", None):
        fail("test_host is required for ios_ui_test.")
    _ios_test(name, rules_apple_ios_ui_test, rules_apple_ios_ui_test_suite, apple_library, **kwargs)
