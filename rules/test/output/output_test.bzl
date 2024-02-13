def _output_test_impl(ctx):
    target_file = None
    all_files = ctx.attr.target[DefaultInfo].files.to_list()
    for f in all_files:
        if f.extension in ["zip", "app", "ipa", "xctest"]:
            target_file = f
            break
    if not target_file:
        target_file = all_files[0]

    exe = ctx.outputs.executable
    ctx.actions.expand_template(
        output = exe,
        template = ctx.file.output_checker,
        is_executable = True,
        substitutions = {
            "%EXPECT%": "( " + " ".join(ctx.attr.expected) + " )",
            "%TARGET%": target_file.short_path,
            "%UNEXPECT%": "( " + " ".join(ctx.attr.unexpected) + " )",
        },
    )
    return [DefaultInfo(runfiles = ctx.runfiles(files = ctx.attr.target[DefaultInfo].files.to_list()))]

output_test = rule(
    _output_test_impl,
    test = True,
    attrs = {
        "expected": attr.string_list(mandatory = True),
        "output_checker": attr.label(default = "//rules/test/output:output_checker.sh", allow_single_file = True),
        "target": attr.label(),
        "unexpected": attr.string_list(mandatory = False, default = []),
    },
    doc = """
    Basic test runner you can add expectations on output. feeds target,
expected, and unexpected to the template
     """,
)
