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
            "%TARGET%": target_file.short_path,
            "%EXPECT%": "( " + " ".join(ctx.attr.expect) + " )",
        },
    )
    return [DefaultInfo(runfiles = ctx.runfiles(files = ctx.attr.target[DefaultInfo].files.to_list()))]

output_test = rule(
    _output_test_impl,
    test = True,
    attrs = {
        "target": attr.label(),
        "output_checker": attr.label(default = "//rules/test/output:output_checker.sh", allow_single_file = True),
        "expect": attr.string_list(mandatory = True),
    },
    doc = """
    Basic test runner you can add expectations on output. feeds target and
expect to the template
     """,
)
