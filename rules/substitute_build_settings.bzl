load("@bazel_skylib//lib:paths.bzl", "paths")

def _substitute_build_settings_impl(ctx):
    substitutions = {}
    for key in ctx.attr.variables:
        value = ctx.attr.variables[key]
        substitutions["${" + key + "}"] = value
        substitutions["$(" + key + ")"] = value

    basename, extension = paths.split_extension(ctx.file.source.basename)
    output = ctx.actions.declare_file("%s.substituted-%s.%s" % (basename, ctx.label.name, extension))
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
