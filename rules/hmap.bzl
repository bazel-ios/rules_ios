"""Header Map rules"""

load("//rules:internal.bzl", "FrameworkInfo")
HeaderMapInfo = provider(
    doc = "Propagates header maps",
    fields = {
        "files": "depset with headermaps",
    },
)

def _make_hmap(actions, headermap_builder, output, namespace, hdrs_lists, hmaps = []):
    """Makes an hmap file.

    Args:
        actions: a ctx.actions struct
        headermap_builder: an executable pointing to @bazel_build_rules_ios//rules/hmap:hmaptool
        output: the output file that will contain the built hmap
        namespace: the prefix to be used for header imports
        hdrs_lists: an array of enumerables containing headers to be added to the hmap
    """
    args = actions.args()
    if namespace:
        args.add("--namespace", namespace)

    args.add("--output", output)

    for hdrs in hdrs_lists:
        args.add_all(hdrs)

    inputs = []
    for hmap in hmaps:
        for _hmap in hmap.to_list():
            inputs.append(_hmap)
            args.add(":" + _hmap.path)

    #args.add(":" + "/tmp/x.hmap")
    args.set_param_file_format(format = "multiline")
    args.use_param_file("@%s")

    actions.run(
        mnemonic = "HmapCreate",
        arguments = [args],
        inputs = depset(inputs),
        executable = headermap_builder,
        outputs = [output],
    )

def _make_headermap_impl(ctx):
    """Implementation of the headermap() rule.

    It creates a text file with
    the mappings and creates an action that calls out to the hmapbuild
    tool included here to create the actual .hmap file.

    :param ctx: context for this rule. See
           https://docs.bazel.build/versions/master/starlark/lib/ctx.html

    :return: provider with the info for this rule
    """
    hdrs_lists = [ctx.files.hdrs]
    hmaps = []
    for provider in ctx.attr.direct_hdr_providers:
        if FrameworkInfo in provider:
            continue

        if apple_common.Objc in provider:
            hdrs_lists.append(provider[apple_common.Objc].direct_headers)
        if CcInfo in provider:
            hdrs_lists.append(provider[CcInfo].compilation_context.direct_headers)

        # We'd need a way to add a prefix into the path for this
        #if HeaderMapInfo in provider:
        #    print("DEP.HeaderMapInfo:", ctx.attr.name, ":", provider[HeaderMapInfo])
        
        if len(hdrs_lists) == 1:
            # means neither apple_common.Objc nor CcInfo in hdr provider target
            fail("direct_hdr_provider %s must contain either 'CcInfo' or 'objc' provider" % provider)

    # Note: this tool doesn't very well virtualize the includes: we can't put a
    # prefix on the arguments
    hmap.make_hmap(
        actions = ctx.actions,
        headermap_builder = ctx.executable._headermap_builder,
        output = ctx.outputs.headermap,
        namespace = ctx.attr.namespace,
        hdrs_lists = hdrs_lists,
        hmaps = hmaps,
    )

    cc_info_provider = CcInfo(
        compilation_context = cc_common.create_compilation_context(
            headers = depset([ctx.outputs.headermap]),
        ),
    )

    providers = [
        apple_common.new_objc_provider(),
        cc_info_provider,
    ]

    hdrs_lists = [l for l in hdrs_lists if l]
    if len(hdrs_lists) > 0:
        providers.append(HeaderMapInfo(
            files = depset([ctx.outputs.headermap]),
        ))

    return providers

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

hmap = struct(
    make_hmap = _make_hmap,
)
