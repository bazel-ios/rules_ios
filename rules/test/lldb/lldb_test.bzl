load("@rules_python//python:defs.bzl", "py_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

# End to end "Shell" test that a breakpoint can resolve a location
# Consider just allow running a breakpoint without crashing
# It does the following
# 1. Take the (compiled) application and boot up a sim matching the SDK and
#    Xcode version
# 2. Set a breakpoint given the `breakpoint_cmd`
# 3. When it stops on the breakpoint, it validates the `variable` matches the
#    `expected_value`
def lldb_test(name, application, breakpoint_cmd, variable, expected_value, **kwargs):
    test_spec = struct(
        breakpoint_cmd = breakpoint_cmd,
        variable_name = variable,
        expected_value = expected_value,
    )

    write_file(
        name = name + ".test_spec",
        out = name + ".test_spec.json",
        content = [test_spec.to_json()],
    )
    py_test(
        name = name,
        main = "@build_bazel_rules_ios//rules/test/lldb:bazel_lldb_test_main.py",
        srcs = [
            "@build_bazel_rules_ios//rules/test/lldb:bazel_lldb_test_main.py",
        ],
        args = [
            "--app",
            "$(execpath " + application + ").ipa",
            # FIXME: find a way to better express this for CI - it's tied into
            # the xcode_version right now
            "--sdk",
            "14.5",
            "--device",
            "'iPhone X'",
            "--spec",
            "$(execpath " + name + ".test_spec" + ")",
        ],
        deps = ["@build_bazel_rules_ios//rules/test/lldb:lldb_test"],
        data = [
            application,
            name + ".test_spec",
        ],
        **kwargs
    )
