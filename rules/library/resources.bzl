def _is_apple_resource_file(file):
    if file.extension in ("xcdatamodeld", "xcmappingmodel"):
        return False

    return True

def _resources_filegroup_impl(ctx):
    files = [f for f in ctx.files.srcs if _is_apple_resource_file(f)]
    return [
        DefaultInfo(
            files = depset(items = files),
        ),
    ]

resources_filegroup = rule(
    implementation = _resources_filegroup_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, allow_empty = True),
    },
    doc = """Wraps a set of srcs for use as `data` in an `objc_library` or `swift_library`,
or `resources` in an `apple_resource_bundle`.
""",
)

def wrap_resources_in_filegroup(name, srcs, **kwargs):
    resources_filegroup(
        name = name,
        srcs = srcs,
        **kwargs
    )
    return name
