"""
Tests for the defines.bzl file.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//rules:plists.bzl", "process_infoplists")

def _test_process_infoplists_impl(ctx):
    env = analysistest.begin(ctx)
    expected_substitutions = ctx.attr.expected_substitutions

    expand_action = analysistest.target_actions(env)[0]
    actual_substitutions = expand_action.substitutions

    asserts.equals(env, expected_substitutions, actual_substitutions)

    return analysistest.end(env)

process_infoplists_test = analysistest.make(
    _test_process_infoplists_impl,
    attrs = {
        "expected_substitutions": attr.string_dict(),
    },
)

def process_infoplists_test_suite(name):
    """
    Test suite for process_infoplists.

    Args:
        name: Name of the test suite.
    Returns:
        Labels of the created tests.
    """

    # Given default xcconfigs
    xcconfig = {
        "CUSTOM_PRODUCT_VERSION": "9.9.9",
    }

    # Given xcconfigs by build setting
    xcconfig_by_build_setting = {
        "//:debug": {
            "CUSTOM_PRODUCT_VERSION": "7.7.7",
        },
        "//:release": {
            "CUSTOM_PRODUCT_VERSION": "8.8.8",
        },
        "//:recursive": {
            "RECURSIVE_CUSTOM_PRODUCT_VERSION": "$(CUSTOM_PRODUCT_VERSION).RECURSIVE",
        },
    }

    # Given this infoplist
    infoplist = {
        "CFBundleShortVersionString": "$(CUSTOM_PRODUCT_VERSION)",
    }

    # Given this infoplists_by_build_setting
    infoplists_by_build_setting = {
        "//:debug": [{
            "CFBundleName": "Debug.$(CUSTOM_PRODUCT_VERSION)",
        }],
        "//:release": [{
            "CFBundleName": "Release.$(CUSTOM_PRODUCT_VERSION)",
        }],
        "//:other": [{
            "CFBundleName": "Other.$(CUSTOM_PRODUCT_VERSION)",
        }],
        "//:recursive": [{
            "CFBundleName": "Recusrive.$(RECURSIVE_CUSTOM_PRODUCT_VERSION)",
        }],
    }

    # When process the plist
    processed_plists = process_infoplists(
        name = name,
        infoplists = [infoplist],
        infoplists_by_build_setting = infoplists_by_build_setting,
        xcconfig = xcconfig,
        xcconfig_by_build_setting = xcconfig_by_build_setting,
    )

    # Then expect substitutions are correct per config_setting based on xcconfig & xcconfig_by_build_setting
    expected_default_substitutions = {
        "${CUSTOM_PRODUCT_VERSION}": "9.9.9",
        "$(CUSTOM_PRODUCT_VERSION)": "9.9.9",
    }
    expected_debug_substitutions = {
        "${CUSTOM_PRODUCT_VERSION}": "7.7.7",
        "$(CUSTOM_PRODUCT_VERSION)": "7.7.7",
    }
    expected_release_substitutions = {
        "${CUSTOM_PRODUCT_VERSION}": "8.8.8",
        "$(CUSTOM_PRODUCT_VERSION)": "8.8.8",
    }
    expected_recursive_substitutions = {
        "${CUSTOM_PRODUCT_VERSION}": "9.9.9",
        "$(CUSTOM_PRODUCT_VERSION)": "9.9.9",
        "${RECURSIVE_CUSTOM_PRODUCT_VERSION}": "9.9.9.RECURSIVE",
        "$(RECURSIVE_CUSTOM_PRODUCT_VERSION)": "9.9.9.RECURSIVE",
    }

    # Then test the default plist is correct
    default_infoplist = processed_plists["//conditions:default"][1]
    process_infoplists_test(
        name = "default_%s" % name,
        target_under_test = default_infoplist,
        expected_substitutions = expected_default_substitutions,
    )

    # Then test the debug default plist is correct
    default_debug_infoplist = processed_plists["//:debug"][1]
    process_infoplists_test(
        name = "default_debug_%s" % name,
        target_under_test = default_debug_infoplist,
        expected_substitutions = expected_debug_substitutions,
    )

    # Then test the release default plist is correct
    default_release_infoplist = processed_plists["//:release"][1]
    process_infoplists_test(
        name = "default_release_%s" % name,
        target_under_test = default_release_infoplist,
        expected_substitutions = expected_release_substitutions,
    )

    # Then test the debug infoplist is correct
    debug_infoplist = processed_plists["//:debug"][1]
    process_infoplists_test(
        name = "debug_%s" % name,
        target_under_test = debug_infoplist,
        expected_substitutions = expected_debug_substitutions,
    )

    # Then test the release infoplist is correct
    release_infoplist = processed_plists["//:release"][1]
    process_infoplists_test(
        name = "release_%s" % name,
        target_under_test = release_infoplist,
        expected_substitutions = expected_release_substitutions,
    )

    # Then test the plist without build settings is correct
    other_infoplist = processed_plists["//:other"][0]
    process_infoplists_test(
        name = "other_%s" % name,
        target_under_test = other_infoplist,
        expected_substitutions = expected_default_substitutions,
    )

    # Then test the plist with xcconfigs that reference other variables is substituted correctly
    recursive_infoplist = processed_plists["//:recursive"][0]
    process_infoplists_test(
        name = "recursive_%s" % name,
        target_under_test = recursive_infoplist,
        expected_substitutions = expected_recursive_substitutions,
    )

    return [
        "default_%s" % name,
        "default_debug_%s" % name,
        "default_release_%s" % name,
        "debug_%s" % name,
        "release_%s" % name,
        "other_%s" % name,
        "recursive_%s" % name,
    ]

def plists_test_suite(name):
    process_infoplists_tests = process_infoplists_test_suite("process_infoplists_test")

    native.test_suite(
        name = name,
        tests = process_infoplists_tests,
    )
