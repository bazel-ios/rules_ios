load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo")

def _basename_pipe_path(f):
    return "%s|%s" % (f.basename, f.path)

def _file_path_if_swift_h(f):
    if (not f.is_source) and (f.basename == f.owner.name + "-Swift.h"):
        return f.path

def _file_path_if_public_hmap(f):
    if f.path.endswith("public_hmap.hmap"):
        return f.path

def _make_headermap_input_file(ctx, namespace, hdrs, flatten_headers):
    """Create a string representing the mappings from headers to their
    namespaced include versions. The format is

    virtual_header_path|real_header_path

    Note the separator is a pipe character.

    :param ctx: The ctx of the rule
    :param namespace: 'foo' in #include <foo/bar.h>
    :param hdrs: list of header that need to be mapped
    :param flatten_headers: boolean value that if set, will "flatten"
           the virtual heders. What this means is that the headers
           will also be added without the namespace or any paths
           (basename).

    :return: Args object that will be spilled to a param file.

    """
    args = ctx.actions.args().use_param_file("%s", use_always = True).set_param_file_format("multiline")
    args.add_all(hdrs, map_each = _basename_pipe_path)
    args.add_all(hdrs, map_each = _file_path_if_swift_h, format_each = "{namespace}-Swift.h|%s".format(namespace = namespace))
    if flatten_headers:
        args.add_all(hdrs, map_each = _basename_pipe_path, format_each = "{namespace}/%s".format(namespace = namespace))
        args.add_all(hdrs, map_each = _file_path_if_swift_h, format_each = "{namespace}/{namespace}-Swift.h|%s".format(namespace = namespace))
    return args

def _make_headermap_merge_hmaps_input_file(ctx, hdrs):
    """:param ctx: The ctx of the rule
    :param hdrs: list of header that need to be mapped

    :return: Args object that will be spilled to a param file.

    """
    args = ctx.actions.args().use_param_file("%s", use_always = True).set_param_file_format("multiline")
    args.add_all(hdrs, map_each = _file_path_if_public_hmap, omit_if_empty = True)
    return ["--merge-hmaps", args]

def _make_headermap_impl(ctx):
    """Implementation of the headermap() rule. It creates a text file with
    the mappings and creates an action that calls out to the hmapbuild
    tool included here to create the actual .hmap file.

    :param ctx: context for this rule. See
           https://docs.bazel.build/versions/master/skylark/lib/ctx.html

    :return: provider with the info for this rule

    """

    input_f = _make_headermap_input_file(ctx, ctx.attr.namespace, depset(ctx.files.hdrs), ctx.attr.flatten_headers)

    # Add a list of headermaps in text or hmap format
    args = []

    transitive_hdrs = []

    # Extract propagated headermaps
    for hdr_provider in ctx.attr.hdr_providers:
        if apple_common.Objc in hdr_provider:
            transitive_hdrs.append(hdr_provider[apple_common.Objc].header)
        elif CcInfo in hdr_provider:
            transitive_hdrs.append(hdr_provider[CcInfo].compilation_context.headers)
        else:
            fail("hdr_provider %s must contain either 'CcInfo' or 'objc' provider" % hdr_provider)
    transitive_hdrs = depset(transitive = transitive_hdrs)

    args.extend(_make_headermap_merge_hmaps_input_file(ctx, transitive_hdrs))

    args += [input_f, ctx.outputs.headermap.path]
    ctx.actions.run(
        inputs = transitive_hdrs,
        mnemonic = "HmapCreate",
        arguments = args,
        executable = ctx.executable._headermap_builder,
        outputs = [ctx.outputs.headermap],
    )
    objc_provider = apple_common.new_objc_provider(
        header = depset([ctx.outputs.headermap]),
    )
    return struct(
        files = depset([ctx.outputs.headermap]),
        providers = [objc_provider],
        objc = objc_provider,
        headers = depset([ctx.outputs.headermap]),
    )

# Derive a headermap from transitive headermaps
# hdrs: a file group containing headers for this rule
# namespace: the Apple style namespace these header should be under
# hdr_providers: rules providing headers. i.e. an `objc_library`
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
        "flatten_headers": attr.bool(
            mandatory = True,
            doc = "Whether headers should be importable with the namespace as a prefix",
        ),
        "hdr_providers": attr.label_list(
            mandatory = False,
            doc = """\
Targets that provide headers.
Targets must have either an Objc or CcInfo provider.""",
            providers = [[apple_common.Objc], [CcInfo]],
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
