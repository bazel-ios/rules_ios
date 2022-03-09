load("@rules_python//python:defs.bzl", "py_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

# End to end "Shell" test that a breakpoint can resolve a location
# Consider just allow running a breakpoint without crashing
# It does the following
# 1. Take the (compiled) application and boot up a sim matching the SDK and
#    Xcode version
# 2. Set a breakpoint given the `set_cmd`
# 3. When it stops on the breakpoint, it validates the `variable` matches the
#    `expected_value`
def ios_lldb_breakpoint_po_test(name, application, set_cmd, variable, expected_value, sdk, device, **kwargs):
    test_spec = struct(
        variable_name = variable,
        expected_value = expected_value,
    )
    _check_cmd(set_cmd)
    initcmds = [
        set_cmd,
        "command script import --allow-reload ./breakpoint.py",
        "breakpoint command add --python-function breakpoint.breakpoint_info_fn  1",
        "run",
    ]
    _ios_breakpoint_test_wrapper(name, application, initcmds, test_spec, sdk, device, **kwargs)

def _check_cmd(set_cmd):
    # This is not super robust but atleast it fails fast
    if (set_cmd.startswith("br ") or set_cmd.startswith("breakpoint ")) == False:
        fail(
            "set_cmd needs some breakpoint set to do anything - got:",
            set_cmd,
        )

# Similar as above but just verify if cmds return successfully. `cmds` is an
# array of LLDB commands that run when `set_cmd` is hit
def ios_lldb_breakpoint_command_test(name, application, set_cmd, cmds, sdk, device, **kwargs):
    test_spec = struct(
        br_hit_commands = cmds,
    )
    _check_cmd(set_cmd)
    initcmds = [
        set_cmd,
        "command script import --allow-reload ./breakpoint.py",
        "breakpoint command add --python-function breakpoint.breakpoint_cmd_fn  1",
        "run",
    ]
    _ios_breakpoint_test_wrapper(name, application, initcmds, test_spec, sdk, device, **kwargs)

def _ios_breakpoint_test_wrapper(name, application, cmds, test_spec, sdk, device, **kwargs):
    write_file(
        name = name + "_test_spec",
        out = name + ".test_spec.json",
        content = [test_spec.to_json()],
    )
    write_file(
        name = name + "_lldbinit",
        out = name + ".lldbinit",
        content = cmds,
    )

    py_test(
        name = name,
        main = "@build_bazel_rules_ios//rules/test/lldb:lldb_breakpoint_test_main.py",
        srcs = [
            "@build_bazel_rules_ios//rules/test/lldb:lldb_breakpoint_test_main.py",
        ],
        args = [
            "--app",
            "$(execpath " + application + ").ipa",
            # Consider finding a way to better express this for github CI -
            # it's tied into the xcode_version right now. We could move this to
            # an idiom of a "test_runner" or the likes
            "--sdk",
            sdk,
            "--device",
            "'" + device + "'",
            "--spec",
            "$(execpath " + name + "_test_spec" + ")",
            "--lldbinit",
            "$(execpath " + name + "_lldbinit" + ")",
        ],
        deps = ["@build_bazel_rules_ios//rules/test/lldb:lldb_test"],
        data = [
            application,
            name + "_test_spec",
            name + "_lldbinit",
        ],
        **kwargs
    )
