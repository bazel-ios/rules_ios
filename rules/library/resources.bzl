def _is_apple_resource_file(file, extensions_to_filter):
    if file.extension in extensions_to_filter:
        return False

    return True

def _resources_filegroup_impl(ctx):
    files = [f for f in ctx.files.srcs if _is_apple_resource_file(file = f, extensions_to_filter = ctx.attr.extensions_to_filter)]
    return [
        DefaultInfo(
            files = depset(items = files),
        ),
    ]

resources_filegroup = rule(
    implementation = _resources_filegroup_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, allow_empty = True),
        "extensions_to_filter": attr.string_list(mandatory = True, allow_empty = True),
    },
    doc = """Wraps a set of srcs for use as `data` in an `objc_library` or `swift_library`,
or `resources` in an `apple_resource_bundle`.
""",
)

def wrap_resources_in_filegroup(name, srcs, extensions_to_filter = [], **kwargs):
    extensions_to_filter = list(extensions_to_filter)
    for x in ("xcdatamodeld", "xcmappingmodel"):
        if x not in extensions_to_filter:
            extensions_to_filter.append(x)
    resources_filegroup(
        name = name,
        srcs = srcs,
        extensions_to_filter = extensions_to_filter,
        **kwargs
    )
    return name
