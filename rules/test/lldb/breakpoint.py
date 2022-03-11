# This program is a mechanism to dump a breakpoint spec from a file to a
# `TestResult json dictionary.
#
# Design principals:
# - Keep the LLDB code simple but emit much information
# - Use LLDB's public command line API as much as possible
# - Testing assertion logic runs outside of LLDB

import lldb
import json
import sys
import os

# Usage:
"""
command script import --allow-reload ./breakpoint.py
breakpoint set --file 'tests/ios/app/App/main.m' --line 6
breakpoint command add --python-function breakpoint.breakpoint_info_fn  1
"""


class TestResult():
    def __init__(self, status):
        self.status = status

    def to_json(self):
        return {
            "status": self.status
        }


def test_file(f):
    return os.path.join(os.environ["TEST_TMPDIR"], f)


def emit_status(debugger, status):
    result = TestResult(status=status)

    with open(test_file("test_result.json"), "w") as out_file:
        result_json = result.to_json()
        json.dump(result_json, out_file)
        json.dump(result_json, sys.stdout)
        print("", flush=True)

    # If we don't flush this it will never get written
    print("exiting_process", flush=True)

    # This will totally stop the process
    debugger.HandleCommand("process kill")
    debugger.HandleCommand("quit")

    # This now relies on being able to terminate LLDB - this is the current
    # state of the world, but do this instead of making our own API
    os._exit(0)


def breakpoint_info_fn(frame, bp_loc, extra_args, internal_dict):
    """ This method tests all key aspects of LLDB debugging inside of Xcode for a variable

        It writes the status into `test_result.json` inside of the LLDB path
    """
    debugger = frame.GetThread().GetProcess().GetTarget().GetDebugger()
    hit_count = bp_loc.GetHitCount()
    print("got_hit_count:", hit_count)

    is_resolved = bp_loc.IsResolved()
    # Resolve key information about the breakpoint, starting with basics
    br = bp_loc.GetBreakpoint()
    resolved_count = br.GetNumResolvedLocations()
    print("got_resolved_count:", resolved_count)

    addr = bp_loc.GetAddress()
    comp_unit = addr.GetCompileUnit()
    compilation_unit_file = comp_unit.GetFileSpec().GetFilename()
    print("got_compilation_unit_file:", compilation_unit_file)

    test_spec_dict = None
    with open(test_file("test_spec.json"), 'r') as test_spec:
        test_spec_dict = json.load(test_spec)
        print("test_spec: ", test_spec_dict)
        variable_name = test_spec_dict["variable_name"]

    variable_result = frame.FindVariable(variable_name)
    print("found_variable:", variable_result)

    if variable_result.IsDynamic():
        dynamic_value = variable_result.GetDynamicValue(use_dynamic=True)
        print("found_dynamic_variable:", dynamic_value)

    variable_result = frame.EvaluateExpression(variable_name)

    object_description = variable_result.GetObjectDescription()
    print("found_object_description:", object_description)
    print("variable_result:", variable_name, "=", object_description)
    # If it doesn't crash here this is fine
    emit_status(debugger, 0)


def breakpoint_cmd_fn(frame, bp_loc, extra_args, internal_dict):
    """ This method runs abitrary commands
    """
    debugger = frame.GetThread().GetProcess().GetTarget().GetDebugger()
    hit_count = bp_loc.GetHitCount()

    test_spec_dict = None
    commands_succeeded = False
    with open(test_file("test_spec.json"), 'r') as test_spec:
        test_spec_dict = json.load(test_spec)
        for command in test_spec_dict["br_hit_commands"]:
            print("execute:", command, flush=True)
            res = lldb.SBCommandReturnObject()
            ci = debugger.GetCommandInterpreter()
            ci.HandleCommand(command, res)
            commands_succeeded = res.Succeeded()
            print("cmd_result:", command, res.GetOutput(), flush=True)

    emit_status(debugger, status=0 if commands_succeeded else 1)


def __lldb_init_module(debugger, internal_dict):
    target = debugger.GetSelectedTarget()
    breakpoints = target.GetNumBreakpoints()
    resolved_count = 0
    for i in range(0, breakpoints):
        br = target.GetBreakpointAtIndex(i)
        locs = br.GetNumResolvedLocations()
        resolved_count += locs
        if locs == 0:
            print("warning - found unresolved breakpoint", br)
            continue

    if resolved_count == 0:
        print(target, flush=True)
        print("error - didn't resolve any breakpoints", flush=True)
        os._exit(1)
