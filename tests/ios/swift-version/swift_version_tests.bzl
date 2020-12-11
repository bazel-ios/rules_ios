load("//rules:framework.bzl", "apple_framework")
load("@build_bazel_rules_swift//test/rules:action_command_line_test.bzl", "action_command_line_test")

def apple_framework_swift_version_test(*, name, srcs = [":empty.swift"], given, expected, not_expected = []):
    framework_name = name + "_" + given.replace(".", "_")
    apple_framework(
        name = framework_name,
        srcs = srcs,
        swift_version = given,
        tags = ["manual"],
    )
    swift_library = framework_name + "_swift"
    action_command_line_test(
        name = "test_" + framework_name,
        mnemonic = "SwiftCompile",
        expected_argv = expected and [
            "-swift-version {}".format(expected),
        ],
        not_expected_argv = not_expected,
        tags = [name],
        target_under_test = swift_library,
    )

def apple_framework_swift_version_test_suite(name = "apple_framework_swift_version"):
    apple_framework_swift_version_test(name = name, given = "4", expected = "4")
    apple_framework_swift_version_test(name = name, given = "4.0", expected = "4")
    apple_framework_swift_version_test(name = name, given = "4.0.0", expected = "4")
    apple_framework_swift_version_test(name = name, given = "4.2", expected = "4.2")
    apple_framework_swift_version_test(name = name, given = "4.2.0", expected = "4.2")
    apple_framework_swift_version_test(name = name, given = "5", expected = "5")
    apple_framework_swift_version_test(name = name, given = "5.0", expected = "5")
    apple_framework_swift_version_test(name = name, given = "5.1", expected = "5")
    apple_framework_swift_version_test(name = name, given = "5.3", expected = "5")

    # currently invalid version numbers
    apple_framework_swift_version_test(name = name, given = "0", expected = None, not_expected = ["-swift-version"])
    apple_framework_swift_version_test(name = name, given = "4.1", expected = "4.1")
    apple_framework_swift_version_test(name = name, given = "4.3.0", expected = "4.3")
    apple_framework_swift_version_test(name = name, given = "6", expected = "6")
    apple_framework_swift_version_test(name = name, given = "6.1", expected = "6")

    native.test_suite(
        name = name,
        tags = [name],
    )
