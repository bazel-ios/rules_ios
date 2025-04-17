"""An analysis test to assert that the default outputs of a target match a specified list."""

load("@bazel_skylib//lib:sets.bzl", "sets")
load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _default_outputs_test(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)

    actual_output_paths = [
        file.short_path
        for file in target_under_test[DefaultInfo].files.to_list()
    ]
    expected_output_paths = [
        target_under_test.label.package + "/" + path
        for path in ctx.attr.expected_output_file_paths
    ]

    asserts.set_equals(
        env,
        sets.make(expected_output_paths),
        sets.make(actual_output_paths),
        "Expected output paths do not match actual output paths",
    )

    return analysistest.end(env)

default_outputs_test = analysistest.make(
    _default_outputs_test,
    attrs = {
        "expected_output_file_paths": attr.string_list(
            mandatory = True,
            allow_empty = False,
            doc = """A list of expected output file paths. The paths are relative to the package of the target under test""",
        ),
    },
)
