# This program is a mechanism to dump a breakpoint spec from a file to a
# `TestResult json dictionary.
#
# Design principals:
# - Keep the LLDB code simple but emit much information
# - Use LLDB's public command line API as much as possible
# - Testing assertion logic runs outside of LLDB

import lldb
import json

# Usage:
"""
command script import --allow-reload ./breakpoint.py
breakpoint set --file 'tests/ios/app/App/main.m' --line 6
breakpoint command add --python-function breakpoint.breakpoint_info_fn  1
"""


class TestResult():
    def __init__(self, resolved_count, compilation_unit_file, expression_result, status):
        self.resolved_count = resolved_count
        self.compilation_unit_file = compilation_unit_file
        self.expression_result = expression_result
        self.status = status

    def to_json(self):
        return {
            "resolved_count": self.resolved_count,
            "compilation_unit_file": self.compilation_unit_file,
            "expression_result": self.expression_result,
            "status": self.status
        }


# breakpoint command add --python-function breakpoint.breakpointfn  1
def breakpoint_info_fn(frame, bp_loc, extra_args, internal_dict):
    debugger = frame.GetThread().GetProcess().GetTarget().GetDebugger()
    hit_count = bp_loc.GetHitCount()
    is_resolved = bp_loc.IsResolved()

    # Resolve key information about the breakpoint, starting with basics
    br = bp_loc.GetBreakpoint()
    print("GOT_BR", br)
    resolved_count = br.GetNumResolvedLocations()
    print("GOT_RESOLVED_COUNT", resolved_count)

    addr = bp_loc.GetAddress()
    comp_unit = addr.GetCompileUnit()
    compilation_unit_file = comp_unit.GetFileSpec().GetFilename()
    print("GOT_COMPILATION_UNIT_FILE", compilation_unit_file)

    # TODO: This should actually handle if variable is None per the test_rule
    variable_name = None
    with open("test_spec.json", 'r') as test_spec:
        test_spec_dict = json.load(test_spec)
        print("TEST_SPEC", test_spec_dict)
        variable_name = test_spec_dict["variable_name"]

    variable_result = frame.FindVariable(variable_name)
    print("FOUND_VARIABLE", variable_result)

    if variable_result.IsDynamic():
        dynamic_value = variable_result.GetDynamicValue(use_dynamic=True)
        print("FOUND_DYNAMIC_VARIABLE", dynamic_value)

    variable_result = frame.EvaluateExpression(variable_name)

    object_description = variable_result.GetObjectDescription()

    print("FOUND_OBJECT_DESCRIPTION", object_description)

    report = TestResult(resolved_count, compilation_unit_file,
                        object_description, True)
    json_dict = report.to_json()
    with open("test_result.json", "w") as out_file:
        json.dump(json_dict, out_file)

    # This will totally stop the process
    debugger.HandleCommand("detach")
    debugger.HandleCommand("exit")
