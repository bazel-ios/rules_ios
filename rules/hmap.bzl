load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo")

def _make_headermap_input_file(namespace, hdrs, flatten_headers, bin_dir_path):
    """Create a string representing the mappings from headers to their
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
        path = hdr.path
        if path.endswith("-Swift.h"):
            path = bin_dir_path + "/" + path
        namespaced_key = namespace + "/" + hdr.basename
        entries.append("{}|{}".format(hdr.basename, path))
        if flatten_headers:
            entries.append("{}|{}".format(namespaced_key, path))
    return "\n".join(entries) + "\n"

def _make_headermap_impl(ctx):
    """Implementation of the headermap() rule. It creates a text file with
    the mappings and creates an action that calls out to the hmapbuild
    tool included here to create the actual .hmap file.

    :param ctx: context for this rule. See
           https://docs.bazel.build/versions/master/skylark/lib/ctx.html

    :return: provider with the info for this rule

    """

    # Write a file for *this* headermap, this is a temporary file
    input_f = ctx.actions.declare_file(ctx.label.name + "_input.txt")
    all_hdrs = []
    for provider in ctx.attr.hdrs:
        all_hdrs += provider.files.to_list()
    out = _make_headermap_input_file(ctx.attr.namespace, all_hdrs, ctx.attr.flatten_headers, ctx.bin_dir.path)
    ctx.actions.write(
        content = out,
        output = input_f,
    )

    # Add a list of headermaps in text or hmap format
    mappings = []
    merge_hmaps = {}
    inputs = [input_f]
    args = []

    # Extract propagated headermaps
    for hdr_provider in ctx.attr.hdr_providers:
        hdrs = []
        if apple_common.Objc in hdr_provider:
            hdrs.extend(hdr_provider[apple_common.Objc].header.to_list())
        elif CcInfo in hdr_provider:
            hdrs.extend(hdr_provider[CcInfo].compilation_context.headers.to_list())
        else:
            fail("hdr_provider must contain either 'CcInfo' or 'objc' provider")

        for hdr in hdrs:
            if SwiftInfo in hdr_provider and hdr.path.endswith("-Swift.h"):
                namespace = ctx.attr.namespace
                basename = hdr.basename

                # Only propogate the Swift header from this module
                # The name of the swift header may be -Swift.h or _Swift-Swift.h
                # dur to bazelizer generated rule naming convention.
                # Because rules_swift outputs the C header with name of the rule not
                # the module.
                normalized_basename = namespace + "-Swift.h"
                if basename in [normalized_basename, namespace + "_Swift-Swift.h"]:
                    inputs.append(hdr)
                    mappings += [namespace + "/" + normalized_basename + "|" + hdr.path]
                    if ctx.attr.flatten_headers:
                        mappings += [normalized_basename + "|" + hdr.path]

            # only merge public header maps
            if hdr.path.endswith("public_hmap.hmap"):
                # Add headermaps
                merge_hmaps[hdr] = True

    if mappings:
        mappings_file = ctx.actions.declare_file(ctx.label.name + ".add_mappings")
        inputs.append(mappings_file)
        ctx.actions.write(
            content = "\n".join(mappings) + "\n",
            output = mappings_file,
        )
        args += ["--add-mappings", mappings_file.path]
    if merge_hmaps:
        paths = []
        for hdr in merge_hmaps.keys():
            inputs.append(hdr)
            paths.append(hdr.path)
        merge_hmaps_file = ctx.actions.declare_file(ctx.label.name + ".merge_hmaps")
        inputs.append(merge_hmaps_file)
        ctx.actions.write(
            content = "\n".join(paths) + "\n",
            output = merge_hmaps_file,
        )
        args += ["--merge-hmaps", merge_hmaps_file.path]

    args += [input_f.path, ctx.outputs.headermap.path]
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
