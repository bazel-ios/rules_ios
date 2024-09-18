"""Example rule which uses `declare_directory` to declare a directory output fake Swift sources."""

def _sources_gen_to_dir_impl(ctx):
    directory = ctx.actions.declare_directory(ctx.attr.output_dir)
    args = ctx.actions.args()
    args.add(directory.path)

    ctx.actions.run_shell(
        arguments = [args],
        command = """mkdir -p "$1" && echo 'let foo = "foo"' > $1/foo.swift && echo 'let bar = "bar"' > $1/baz.swift""",
        inputs = [],
        outputs = [directory],
    )

    return [
        DefaultInfo(files = depset([directory])),
    ]


sources_gen_to_dir = rule(
    implementation = _sources_gen_to_dir_impl,
    attrs = {
        "output_dir": attr.string(),
    },
)
