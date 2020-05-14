"""Header Map rules"""

HeaderMapInfo = provider(
    doc = "Propagates header maps",
    fields = {
        "files": "depset with headermaps",
    },
)

def _make_headermap_input_file(namespace, hdrs, flatten_headers):
    """Create a header map input file.

    This function creates a string representing the mappings from headers to their
    namespaced include versions. The format is

    virtual_header_path|real_header_path

    Note the separator is a pipe character.

    :param namespace: 'foo' in #include <foo/bar.h>
    :param hdrs: list of header that need to be mapped
    :param flatten_headers: boolean value that if set, will "flatten"
           the virtual heders. What this means is that the headers
           will also be added without the namespace or any paths
           (basename).

    :return: string with all the headers in the above mentioned
    format. This can be saved to a file and read by the hmapbuild tool
    included here to create a header map file.
    """

    entries = []
    for hdr in hdrs:
        namespaced_key = namespace + "/" + hdr.basename
        entries.append("{}|{}".format(hdr.basename, hdr.path))
        if flatten_headers:
            entries.append("{}|{}".format(namespaced_key, hdr.path))
    return "\n".join(entries) + "\n"

def _make_headermap_impl(ctx):
    """Implementation of the headermap() rule.

    It creates a text file with
    the mappings and creates an action that calls out to the hmapbuild
    tool included here to create the actual .hmap file.

    :param ctx: context for this rule. See
           https://docs.bazel.build/versions/master/skylark/lib/ctx.html

    :return: provider with the info for this rule
    """

    # Write a file for *this* headermap, this is a temporary file
    input_f = ctx.actions.declare_file(ctx.label.name + "_input.txt")
    all_hdrs = list(ctx.files.hdrs)
    for provider in ctx.attr.direct_hdr_providers:
        if apple_common.Objc in provider:
            all_hdrs += provider[apple_common.Objc].direct_headers
        elif CcInfo in provider:
            all_hdrs += provider[CcInfo].compilation_context.direct_headers
        else:
            fail("direct_hdr_provider %s must contain either 'CcInfo' or 'objc' provider" % provider)

    out = _make_headermap_input_file(ctx.attr.namespace, all_hdrs, ctx.attr.flatten_headers)
    ctx.actions.write(
        content = out,
        output = input_f,
    )

    # Add a list of headermaps in text or hmap format
    inputs = [input_f]
    args = [input_f.path, ctx.outputs.headermap.path]
    ctx.actions.run(
        inputs = inputs,
        mnemonic = "HmapCreate",
        arguments = args,
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
            mandatory = True,
            doc = "The prefix to be used for header imports when flatten_headers is true",
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
        "flatten_headers": attr.bool(
            mandatory = True,
            doc = "Whether headers should be importable with the namespace as a prefix",
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
