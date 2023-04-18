load("@build_bazel_rules_apple//apple:ios.bzl", rules_apple_ios_ui_test = "ios_ui_test", rules_apple_ios_ui_test_suite = "ios_ui_test_suite", rules_apple_ios_unit_test = "ios_unit_test", rules_apple_ios_unit_test_suite = "ios_unit_test_suite")
load("@bazel_skylib//lib:types.bzl", "types")
load("//rules:library.bzl", "apple_library")
load("//rules:plists.bzl", "process_infoplists")
load("//rules/internal:framework_middleman.bzl", "dep_middleman", "framework_middleman")

_IOS_TEST_KWARGS = [
    "args",
    "bundle_id",
    "env",
    "flaky",
    "frameworks",
    "infoplists",
    "minimum_os_version",
    "provisioning_profile",
    "resources",
    "shard_count",
    "size",
    "tags",
    "test_coverage_manifest",
    "test_filter",
    "test_host",
    "timeout",
    "visibility",
]

def _ios_test(name, test_rule, test_suite_rule, apple_library, infoplists_by_build_setting = {}, split_name_to_kwargs = {}, internal_test_deps = [], **kwargs):
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
        split_name_to_kwargs: A dictionary of suffixes to kwargs that will be passed into the "split" test bundle. The suffix will be appended to the name of the suite.
        **kwargs: Arguments passed to the apple_library and test_rule rules as appropriate.
    """

    testonly = kwargs.pop("testonly", True)
    ios_test_kwargs = {arg: kwargs.pop(arg) for arg in _IOS_TEST_KWARGS if arg in kwargs}
    ios_test_kwargs["data"] = kwargs.pop("test_data", [])

    test_exec_properties = kwargs.pop("test_exec_properties", None)
    if test_exec_properties:
        ios_test_kwargs["exec_properties"] = test_exec_properties

    if ios_test_kwargs.get("test_host", None) == True:
        ios_test_kwargs["test_host"] = "@build_bazel_rules_ios//rules/test_host_app:iOS-%s-AppHost" % ios_test_kwargs.get("minimum_os_version")

    if "runner" in kwargs and "runners" in kwargs:
        fail("cannot specify both runner and runners for %s" % name)

    runner = kwargs.pop("runner", kwargs.pop("runners", None))

    # Deduplicate against the test deps
    if ios_test_kwargs.get("test_host", None):
        host_args = [ios_test_kwargs["test_host"]]
    else:
        host_args = []
    library = apple_library(name = name, namespace_is_module_name = False, platforms = {"ios": ios_test_kwargs.get("minimum_os_version")}, testonly = testonly, **kwargs)

    # Setup framework middlemen - need to process deps and libs
    fw_name = name + ".framework_middleman"
    framework_middleman(name = fw_name, framework_deps = kwargs.get("deps", []) + library.lib_names, testonly = testonly, tags = ["manual"])
    frameworks = [fw_name] + ios_test_kwargs.pop("frameworks", [])

    dep_name = name + ".dep_middleman"
    dep_middleman(name = dep_name, deps = kwargs.get("deps", []) + library.lib_names, testonly = testonly, tags = ["manual"], test_deps = host_args)

    infoplists = process_infoplists(
        name = name,
        infoplists = ios_test_kwargs.pop("infoplists", []),
        infoplists_by_build_setting = infoplists_by_build_setting,
        xcconfig = kwargs.get("xcconfig", {}),
        xcconfig_by_build_setting = kwargs.get("xcconfig_by_build_setting", {}),
    )

    if split_name_to_kwargs and len(split_name_to_kwargs) > 0:
        tests = []
        for suffix, split_kwargs in split_name_to_kwargs.items():
            test_name = "{}_{}".format(name, suffix)

            all_kwargs = {}
            all_kwargs.update(ios_test_kwargs)
            all_kwargs.update(split_kwargs)

            if runner and ("runner" in all_kwargs or "runners" in all_kwargs):
                fail("cannot use runner/s attribute in both split and top level kwargs for %s" % test_name)

            if not runner:
                split_runner = all_kwargs.pop("runner", all_kwargs.pop("runners", None))
            else:
                split_runner = runner

            split_rule = test_rule
            if split_runner:
                if types.is_list(runner):
                    all_kwargs["runners"] = split_runner
                    split_rule = test_suite_rule
                else:
                    all_kwargs["runner"] = split_runner

            tests.append(test_name)
            split_rule(
                name = test_name,
                deps = [dep_name] + internal_test_deps,
                frameworks = frameworks,
                testonly = testonly,
                infoplists = select(infoplists),
                **all_kwargs
            )
        test_suite_visibility = ios_test_kwargs.get("visibility", None)
        test_suite_tags = ios_test_kwargs.get("tags", [])
        native.test_suite(name = name, tests = tests, visibility = test_suite_visibility, tags = test_suite_tags)
    else:
        rule = test_rule
        if runner:
            if types.is_list(runner):
                ios_test_kwargs["runners"] = runner
                rule = test_suite_rule
            else:
                ios_test_kwargs["runner"] = runner

        rule(
            name = name,
            deps = [dep_name] + internal_test_deps,
            frameworks = frameworks,
            infoplists = select(infoplists),
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

def ios_unit_snapshot_test(name, apple_library = apple_library, **kwargs):
    """
    Builds and packages iOS Unit Snapshot Tests.

    Args:
        name: The name of the UI test.
        apple_library: The macro used to package sources into a library.
        **kwargs: Arguments passed to the apple_library and ios_unit_test rules as appropriate.
    """
    _ios_test(name, rules_apple_ios_unit_test, rules_apple_ios_unit_test_suite, apple_library, internal_test_deps = ["@bazel_tools//tools/cpp/runfiles"], **kwargs)
