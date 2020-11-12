load("@build_bazel_rules_apple//apple:ios.bzl", rules_apple_ios_unit_test = "ios_unit_test", rules_apple_ios_unit_test_suite = "ios_unit_test_suite")
load("@bazel_skylib//lib:types.bzl", "types")
load("//rules:library.bzl", "apple_library")

_IOS_UNIT_TEST_KWARGS = [
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
]

def ios_unit_test(name, apple_library = apple_library, **kwargs):
    """
    Builds and packages iOS Unit Tests.

    Args:
        name: The name of the unit test.
        apple_library: The macro used to package sources into a library.
        **kwargs: Arguments passed to the apple_library and ios_unit_test rules as appropriate.
    """

    unit_test_kwargs = {arg: kwargs.pop(arg) for arg in _IOS_UNIT_TEST_KWARGS if arg in kwargs}

    unit_test_kwargs["data"] = kwargs.pop("test_data", [])
    if unit_test_kwargs.get("test_host", None) == True:
        unit_test_kwargs["test_host"] = "@build_bazel_rules_ios//rules/test_host_app:iOS-%s-AppHost" % unit_test_kwargs.get("minimum_os_version")

    if "runner" in kwargs and "runners" in kwargs:
        fail("cannot specify both runner and runners for %s" % name)

    runner = kwargs.pop("runner", kwargs.pop("runners", None))
    rule = rules_apple_ios_unit_test
    if runner:
        if types.is_list(runner):
            unit_test_kwargs["runners"] = runner
            rule = rules_apple_ios_unit_test_suite
        else:
            unit_test_kwargs["runner"] = runner

    library = apple_library(name = name, namespace_is_module_name = False, platforms = {"ios": unit_test_kwargs.get("minimum_os_version")}, **kwargs)

    local_debug_options_for_swift = []
    if library.has_swift_sources and unit_test_kwargs.get("test_host", None) == None:
        local_debug_options_for_swift.append("@build_bazel_rules_ios//rules:_LocalDebugOptions")

    rule(
        name = name,
        deps = library.lib_names + select({
            "@build_bazel_rules_ios//rules:local_debug_options": local_debug_options_for_swift,
            "//conditions:default": [],
        }),
        **unit_test_kwargs
    )
