def _substitute_build_settings_impl(ctx):
    substitutions = {}
    for key in ctx.attr.variables:
        value = ctx.attr.variables[key]
        substitutions["${" + key + "}"] = value
        substitutions["$(" + key + ")"] = value

    # Resolve any substitutions in the substitutions.
    # i.e. key1 = "foo", key2 = "$(key1)bar" -> key2 = "foobar"
    # This needs to be done before expanding the template otherwise they
    # get substituted as is without resolving the inner substitutions.
    for (key, value) in substitutions.items():
        for (sub_key, sub_value) in substitutions.items():
            if key in sub_value:
                substitutions[sub_key] = sub_value.replace(key, value)

    extension = ctx.file.source.extension
    output = ctx.actions.declare_file("%s.%s" % (ctx.label.name, extension))
    ctx.actions.expand_template(
        template = ctx.file.source,
        output = output,
        substitutions = substitutions,
        is_executable = False,
    )

    return [
        DefaultInfo(files = depset([output])),
    ]

substitute_build_settings = rule(
    implementation = _substitute_build_settings_impl,
    fragments = ["apple"],
    output_to_genfiles = True,
    attrs = {
        "source": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The file to be expanded",
        ),
        "variables": attr.string_dict(
            allow_empty = True,
            mandatory = False,
            default = {},
            doc = """\
A mapping of settings to their values to be expanded.
The setting names should not include `$`s""",
        ),
    },
    doc = """\
Does Xcode-style build setting substitutions into the given source file.
""",
)
