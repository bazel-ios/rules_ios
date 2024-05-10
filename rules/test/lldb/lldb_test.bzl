load("@bazel_skylib//rules:write_file.bzl", "write_file")

# End to end "Shell" test that a breakpoint can resolve a location
# Consider just allow running a breakpoint without crashing
# It does the following
# 1. Take the (compiled) application and boot up a sim matching the SDK and
#    Xcode version
# 2. Set a breakpoint given the `set_cmd`
# 3. When it stops on the breakpoint, it validates the `variable` matches the
#    `expected_value`
def ios_lldb_breakpoint_po_test(name, application, set_cmd, variable, sdk, device, expected_value = None, lldbinit = None, **kwargs):
    test_spec = struct(
        variable_name = variable,
        substrs = (["variable_result: " + variable + " = " + expected_value] if expected_value else []),
    )
    _check_cmd(set_cmd)
    initcmds = [
        set_cmd,
        # Ensure that the platform dir is set correctly here - "platform shell pwd"
        "command script import --allow-reload $(location @build_bazel_rules_ios//rules/test/lldb:breakpoint.py)",
        "breakpoint command add --python-function breakpoint.breakpoint_info_fn  1",
        "continue",
    ]
    _ios_breakpoint_test_wrapper(name, application, initcmds, test_spec, sdk, device, lldbinit = lldbinit, **kwargs)

def _lldbinit_impl(ctx):
    # Resolve the file expanding variables
    cmd_tuple = ctx.resolve_command(command = ctx.attr.content, expand_locations = True)
    if len(cmd_tuple) < 1:
        fail("Unexpected resolution", cmd_tuple)
    content = cmd_tuple[1][2]
    ctx.actions.write(
        output = ctx.outputs.out,
        content = content,
    )

    files = depset(direct = [ctx.outputs.out])
    runfiles = ctx.runfiles(files = [ctx.outputs.out])
    is_executable = False
    if is_executable:
        return [DefaultInfo(files = files, runfiles = runfiles, executable = ctx.outputs.out)]
    else:
        return [DefaultInfo(files = files, runfiles = runfiles)]

_lldbinit = rule(
    implementation = _lldbinit_impl,
    attrs = {
        "content": attr.string(mandatory = True),
        "out": attr.output(mandatory = True),
        "deps": attr.label_list(mandatory = False, allow_files = True),
    },
    doc = "Setup an lldbinit file",
)

def _check_cmd(set_cmd):
    # This is not super robust but atleast it fails fast
    if (set_cmd.startswith("br ") or set_cmd.startswith("breakpoint ")) == False:
        fail(
            "set_cmd needs some breakpoint set to do anything - got:",
            set_cmd,
        )

# Similar as above but just verify if cmds return successfully. `cmds` is an
# array of LLDB commands that run when `set_cmd` is hit
def ios_lldb_breakpoint_command_test(name, application, set_cmd, cmds, sdk, device, match_substrs = [], lldbinit = None, **kwargs):
    test_spec = struct(
        br_hit_commands = cmds,
        substrs = match_substrs,
    )
    _check_cmd(set_cmd)
    initcmds = [
        set_cmd,
        # Ensure that the platform dir is set correctly here - "platform shell pwd"
        "command script import --allow-reload $(location @build_bazel_rules_ios//rules/test/lldb:breakpoint.py)",
        "breakpoint command add --python-function breakpoint.breakpoint_cmd_fn  1",
        "continue",
    ]
    _ios_breakpoint_test_wrapper(name, application, initcmds, test_spec, sdk, device, lldbinit = lldbinit, **kwargs)

def _ios_breakpoint_test_wrapper(name, application, cmds, test_spec, sdk, device, lldbinit, **kwargs):
    write_file(
        name = name + "_test_spec",
        out = name + ".test_spec.json",
        content = [json.encode(test_spec)],
    )

    lldbinit_deps = ["@build_bazel_rules_ios//rules/test/lldb:breakpoint.py"]
    if lldbinit:
        cmds = ["command source $(execpath " + lldbinit + ")"] + cmds
        lldbinit_deps.append(lldbinit)

    _lldbinit(
        name = name + "_lldbinit",
        out = name + ".lldbinit",
        content = "\n".join(cmds),
        deps = lldbinit_deps,
        visibility = ["//visibility:public"],
    )

    native.py_test(
        name = name,
        main = "@build_bazel_rules_ios//rules/test/lldb:lldb_breakpoint_test_main.py",
        srcs = [
            "@build_bazel_rules_ios//rules/test/lldb:lldb_breakpoint_test_main.py",
        ],
        srcs_version = "PY3",
        args = [
            "--app",
            "$(execpath " + application + ").app",
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
        ] + ([lldbinit] if lldbinit else []),
        **kwargs
    )
