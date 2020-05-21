"""Header Map rules"""

HeaderMapInfo = provider(
    doc = "Propagates header maps",
    fields = {
        "files": "depset with headermaps",
    },
)

def _make_headermap_impl(ctx):
    """Implementation of the headermap() rule.

    It creates a text file with
    the mappings and creates an action that calls out to the hmapbuild
    tool included here to create the actual .hmap file.

    :param ctx: context for this rule. See
           https://docs.bazel.build/versions/master/skylark/lib/ctx.html

    :return: provider with the info for this rule
    """

    # Add a list of headermaps in text or hmap format
    args = ctx.actions.args()
    if ctx.attr.namespace:
        args.add("--namespace", ctx.attr.namespace)

    args.add("--output", ctx.outputs.headermap.path)

    args.add_all(ctx.files.hdrs)
    for provider in ctx.attr.direct_hdr_providers:
        if apple_common.Objc in provider:
            args.add_all(provider[apple_common.Objc].direct_headers)
        elif CcInfo in provider:
            args.add_all(provider[CcInfo].compilation_context.direct_headers)
        else:
            fail("direct_hdr_provider %s must contain either 'CcInfo' or 'objc' provider" % provider)

    args.set_param_file_format(format = "multiline")
    args.use_param_file("@%s")
    ctx.actions.run(
        mnemonic = "HmapCreate",
        arguments = [args],
        executable = ctx.executable._headermap_builder,
        outputs = [ctx.outputs.headermap],
    )

    objc_provider = apple_common.new_objc_provider(
        header = depset([ctx.outputs.headermap]),
    )
    cc_info_provider = CcInfo(compilation_context = objc_provider.compilation_context)

    return [
        HeaderMapInfo(
            files = depset([ctx.outputs.headermap]),
        ),
        objc_provider,
        cc_info_provider,
    ]

# Derive a headermap from transitive headermaps
# hdrs: a file group containing headers for this rule
# namespace: the Apple style namespace these header should be under
headermap = rule(
    implementation = _make_headermap_impl,
    output_to_genfiles = True,
    attrs = {
        "namespace": attr.string(
            mandatory = False,
            doc = "The prefix to be used for header imports",
        ),
        "hdrs": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "The list of headers included in the headermap",
        ),
        "direct_hdr_providers": attr.label_list(
            mandatory = False,
            doc = "Targets whose direct headers should be added to the list of hdrs",
        ),
        "_headermap_builder": attr.label(
            executable = True,
            cfg = "host",
            default = Label(
                "//rules/hmap:hmaptool",
            ),
        ),
    },
    outputs = {"headermap": "%{name}.hmap"},
    doc = """\
Creates a binary headermap file from the given headers,
suitable for passing to clang.

This can be used to allow headers to be imported at a consistent path,
regardless of the package structure being used.
    """,
)
