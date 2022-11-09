"""
Tests for the defines.bzl file.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//rules/library:xcconfig.bzl", "merge_xcconfigs")

def _test_merge_xcconfigs_impl(ctx):
    env = unittest.begin(ctx)

    # Given xcconfig_a which has a three string values and a single list value
    xcconfig_a = {
        "VALUE_1": "a",
        "VALUE_2": "b",
        "VALUE_3": "c",
        "LIST_VALUE_1": ["a", "b"],
    }

    # Given xcconfig_b which has two string values and two list values
    xcconfig_b = {
        "VALUE_1": "overriden",
        "VALUE_3": ["c"],
        "VALUE_4": "d",
        "LIST_VALUE_1": ["added"],
        "LIST_VALUE_2": ["d"],
    }

    # When we merge them
    merged = merge_xcconfigs(xcconfig_a, xcconfig_b)

    # Then expect that the string values are overriden in later xcconfigs
    # and that list values are concatenated
    asserts.equals(env, merged["VALUE_1"], "overriden")
    asserts.equals(env, merged["VALUE_2"], "b")
    asserts.equals(env, merged["VALUE_3"], ["c"])
    asserts.equals(env, merged["VALUE_4"], "d")
    asserts.equals(env, merged["LIST_VALUE_1"], ["a", "b", "added"])
    asserts.equals(env, merged["LIST_VALUE_2"], ["d"])

    return unittest.end(env)

merge_xcconfigs_test = unittest.make(_test_merge_xcconfigs_impl)

def xcconfig_test_suite(name):
    unittest.suite(
        name,
        merge_xcconfigs_test,
    )
