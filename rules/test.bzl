load("@build_bazel_rules_apple//apple/internal/testing:ios_rules.bzl", _ios_internal_ui_test_bundle = "ios_internal_ui_test_bundle", _ios_internal_unit_test_bundle = "ios_internal_unit_test_bundle", _ios_ui_test = "ios_ui_test", _ios_unit_test = "ios_unit_test")
load("@bazel_skylib//lib:types.bzl", "types")
load("//rules:library.bzl", "apple_library")
load("//rules:plists.bzl", "process_infoplists")
load("//rules/internal:framework_middleman.bzl", "dep_middleman", "framework_middleman")

_IOS_TEST_KWARGS = [
    "args",
    "bundle_id",
    "bundle_name",
    "env",
    "features",
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

_APPLE_BUNDLE_ATTRS = {
    x: None
    for x in [
        "additional_contents",
        "deps",
        "bundle_id",
        "bundle_name",
        "families",
        "features",
        "frameworks",
        "infoplists",
        "linkopts",
        "minimum_os_version",
        "provisioning_profile",
        "resources",
        "test_host",
    ]
}

_DEFAULT_APPLE_TEST_RUNNER = "@build_bazel_rules_apple//apple/testing/default_runner:ios_default_runner"

def _make_runner_split(name, runner, **in_split):
    split = {}
    split.update(in_split)
    split.pop("runners", None)
    split["runner"] = runner
    return split

def _make_named_split(name, split_kwargs, **in_split):
    split = {}
    split.update(in_split)
    split.update(split_kwargs)
    return split

def _make_test_suite_splits(factory, name, **in_kwargs):
    """
    Helper function to split up a test for named splits and runners splits

    At the end of the day, we need to able to control how many tests / bundles
    there are for sharding by class, otherwise it would recompile many times.

    Finally - you can set the splits to be whatever you want.
    """
    split_name_to_kwargs = in_kwargs.pop("split_name_to_kwargs", {})
    splits = {}
    if split_name_to_kwargs and len(split_name_to_kwargs) > 0:
        for suffix, split_kwargs in split_name_to_kwargs.items():
            test_name = "{}_{}".format(name, suffix)
            splits[test_name] = factory.make_named_split(name, split_kwargs, **in_kwargs)

    runners = in_kwargs.pop("runners", [])
    if runners and len(runners) > 0:
        splits_by_runners = {}
        if len(splits) == 0:
            splits[name] = in_kwargs
        for runner in runners:
            runner_name = runner.rsplit(":", 1)[-1]
            for in_test_name, in_split in splits.items():
                test_name = "{}_{}".format(in_test_name, runner_name)
                splits_by_runners[test_name] = factory.make_runner_split(name, runner, **in_split)
        splits = splits_by_runners
    return splits

def _make_test_suite(factory, name, test_rule, **test_kwargs):
    splits = factory.make_test_suite_splits(factory, name, **test_kwargs)
    tests = []
    for split_name, split in splits.items():
        tests.append(split_name)
        factory.make_test(split_name, test_rule, **split)
    test_suite_visibility = test_kwargs.get("visibility", None)
    test_suite_tags = test_kwargs.get("tags", [])
    native.test_suite(name = name, tests = tests, visibility = test_suite_visibility, tags = test_suite_tags)

def _make_test(name, test_rule, **kwargs):
    """
    Helper to create an individual test
    """
    runner = kwargs.pop("runner", None) or _DEFAULT_APPLE_TEST_RUNNER
    test_attrs = {k: v for (k, v) in kwargs.items() if k not in _APPLE_BUNDLE_ATTRS}

    test_rule(
        name = name,
        runner = runner,
        test_host = kwargs.pop("test_host", None),
        deps = kwargs.pop("deps", []),
        testonly = kwargs.pop("testonly", True),
        minimum_os_version = kwargs.pop("minimum_os_version"),
        **test_attrs
    )

def _make_tests(factory, name, test_rule, **kwargs):
    """
    Main entry point of generating tests"
    """

    # If the user indicates they want more than one test we will generate one
    if "runners" in kwargs or "split_name_to_kwargs" in kwargs:
        factory.make_test_suite(factory, name, test_rule, **kwargs)
    else:
        factory.make_test(name, test_rule, **kwargs)

default_test_factory = struct(
    make_tests = _make_tests,
    make_test_suite = _make_test_suite,
    make_test_suite_splits = _make_test_suite_splits,
    make_runner_split = _make_runner_split,
    make_named_split = _make_named_split,
    make_test = _make_test,
)

def _ios_test(name, bundle_rule, test_rule, test_factory, apple_library, infoplists_by_build_setting = {}, split_name_to_kwargs = {}, internal_test_deps = [], **kwargs):
    """
    Builds and packages iOS Unit/UI Tests.

    Args:
        name: The name of the unit test.
        bundle_rule: The underlying rules_apple test suite rule.
        test_rule: The underlying rules_apple test rule.
        test_factory: The factory object used to generate tests.
        apple_library: The macro used to package sources into a library.
        infoplists_by_build_setting: A dictionary of infoplists grouped by bazel build setting.

                                     Each value is applied if the respective bazel build setting
                                     is resolved during the analysis phase.

                                     If '//conditions:default' is not set the value in 'infoplists'
                                     is set as default.
        split_name_to_kwargs: A dictionary of suffixes to kwargs that will be passed into the "split" test bundle. The suffix will be appended to the name of the suite.
        internal_test_deps: Internal test dependencies.
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

    runners = kwargs.pop("runners", None)
    runner = kwargs.pop("runner", _DEFAULT_APPLE_TEST_RUNNER)
    if "runner" in kwargs and (runners and runners != []):
        fail("cannot specify both runner and runners for %s" % name)
    if runners:
        ios_test_kwargs["runners"] = runners
    elif types.is_list(runner):
        # `runner` attribute has unfortunately always supported a list.
        ios_test_kwargs["runners"] = runner
    else:
        ios_test_kwargs["runner"] = runner

    if split_name_to_kwargs:
        ios_test_kwargs["split_name_to_kwargs"] = split_name_to_kwargs

    library = apple_library(name = name, namespace_is_module_name = False, platforms = {"ios": ios_test_kwargs.get("minimum_os_version")}, testonly = testonly, **kwargs)

    # Setup framework middlemen - need to process deps and libs
    fw_name = name + ".framework_middleman"
    framework_middleman(
        name = fw_name,
        framework_deps = kwargs.get("deps", []) + library.lib_names,
        testonly = testonly,
        tags = ["manual"],
        platform_type = "ios",
        minimum_os_version = ios_test_kwargs.get("minimum_os_version"),
    )
    frameworks = [fw_name] + ios_test_kwargs.pop("frameworks", [])

    dep_name = name + ".dep_middleman"
    dep_middleman(
        name = dep_name,
        deps = kwargs.get("deps", []) + library.lib_names,
        testonly = testonly,
        tags = ["manual"],
        platform_type = "ios",
        minimum_os_version = ios_test_kwargs.get("minimum_os_version"),
    )

    infoplists = process_infoplists(
        name = name,
        infoplists = ios_test_kwargs.pop("infoplists", []),
        infoplists_by_build_setting = infoplists_by_build_setting,
        xcconfig = kwargs.get("xcconfig", {}),
        xcconfig_by_build_setting = kwargs.get("xcconfig_by_build_setting", {}),
    )

    # Set this to a single __internal__ test bundle.
    test_bundle_name = name + ".__internal__.__test_bundle"
    bundle_attrs = {k: v for (k, v) in ios_test_kwargs.items() if k in _APPLE_BUNDLE_ATTRS}
    bundle_name = bundle_attrs.pop("bundle_name", name)
    bundle_rule(
        name = test_bundle_name,
        bundle_name = bundle_name,
        test_bundle_output = "{}.zip".format(bundle_name),
        testonly = True,
        frameworks = frameworks,
        infoplists = select(infoplists),
        deps = [dep_name] + internal_test_deps,
        **bundle_attrs
    )
    ios_test_kwargs["deps"] = [test_bundle_name]
    test_factory.make_tests(test_factory, name, test_rule, **ios_test_kwargs)

def ios_unit_test(name, apple_library = apple_library, test_factory = default_test_factory, **kwargs):
    """
    Builds and packages iOS Unit Tests.

    Args:
        name: The name of the unit test.
        apple_library: The macro used to package sources into a library.
        test_factory: Use this to generate other variations of tests.
        **kwargs: Arguments passed to the apple_library and ios_unit_test rules as appropriate.
    """
    infoplists_by_build_setting = kwargs.pop("infoplists_by_build_setting", {})
    split_name_to_kwargs = kwargs.pop("split_name_to_kwargs", {})
    internal_test_deps = kwargs.pop("internal_test_deps", [])

    _ios_test(
        name = name,
        bundle_rule = _ios_internal_unit_test_bundle,
        test_rule = _ios_unit_test,
        test_factory = test_factory,
        apple_library = apple_library,
        infoplists_by_build_setting = infoplists_by_build_setting,
        split_name_to_kwargs = split_name_to_kwargs,
        internal_test_deps = internal_test_deps,
        **kwargs
    )

def ios_ui_test(name, apple_library = apple_library, test_factory = default_test_factory, **kwargs):
    """
    Builds and packages iOS UI Tests.

    Args:
        name: The name of the UI test.
        apple_library: The macro used to package sources into a library.
        test_factory: Use this to generate other variations of tests.
        **kwargs: Arguments passed to the apple_library and ios_ui_test rules as appropriate.
    """
    if not kwargs.get("test_host", None):
        fail("test_host is required for ios_ui_test.")

    infoplists_by_build_setting = kwargs.pop("infoplists_by_build_setting", {})
    split_name_to_kwargs = kwargs.pop("split_name_to_kwargs", {})
    internal_test_deps = kwargs.pop("internal_test_deps", [])

    _ios_test(
        name = name,
        bundle_rule = _ios_internal_ui_test_bundle,
        test_rule = _ios_ui_test,
        test_factory = test_factory,
        apple_library = apple_library,
        infoplists_by_build_setting = infoplists_by_build_setting,
        split_name_to_kwargs = split_name_to_kwargs,
        internal_test_deps = internal_test_deps,
        **kwargs
    )

def ios_unit_snapshot_test(name, apple_library = apple_library, test_factory = default_test_factory, **kwargs):
    """
    Builds and packages iOS Unit Snapshot Tests.

    Args:
        name: The name of the UI test.
        apple_library: The macro used to package sources into a library.
        test_factory: Use this to generate other variations of tests.
        **kwargs: Arguments passed to the apple_library and ios_unit_test rules as appropriate.
    """
    infoplists_by_build_setting = kwargs.pop("infoplists_by_build_setting", {})
    split_name_to_kwargs = kwargs.pop("split_name_to_kwargs", {})
    internal_test_deps = kwargs.pop("internal_test_deps", [])

    _ios_test(
        name = name,
        bundle_rule = _ios_internal_unit_test_bundle,
        test_rule = _ios_unit_test,
        test_factory = test_factory,
        apple_library = apple_library,
        infoplists_by_build_setting = infoplists_by_build_setting,
        split_name_to_kwargs = split_name_to_kwargs,
        internal_test_deps = internal_test_deps,
        **kwargs
    )
