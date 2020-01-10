VFSOverlay = provider()

def _pipe_join(x):
    return "%s|%s" % (x[0].path, x[1].path)

def _vfs_overlay_impl(ctx):
    args = ctx.actions.args().set_param_file_format("multiline").use_param_file(param_file_arg = "%s", use_always = True)
    transitive_files = []
    for dep in ctx.attr.deps:
        if not VFSOverlay in dep:
            continue
        transitive_files.append(dep[VFSOverlay].files)
        args.add_all(dep[VFSOverlay].files, map_each = _pipe_join)
    ctx.actions.run(
        mnemonic = "WritingVFSOverlay",
        executable = ctx.executable._vfs_overlay_writer,
        arguments = [ctx.outputs.vfs_overlay.path, args],
        outputs = [ctx.outputs.vfs_overlay],
    )
    return [
        apple_common.new_objc_provider(header = depset([ctx.outputs.vfs_overlay])),
        VFSOverlay(files = depset(transitive = transitive_files)),
        DefaultInfo(files = depset([ctx.outputs.vfs_overlay])),
    ]

vfs_overlay = rule(
    implementation = _vfs_overlay_impl,
    attrs = {
        "deps": attr.label_list(
            mandatory = False,
            allow_empty = True,
            default = [],
        ),
        "files": attr.label_keyed_string_dict(
            default = {},
            allow_empty = True,
            mandatory = False,
            allow_files = True,
        ),
        "_vfs_overlay_writer": attr.label(
            cfg = "host",
            default = Label(
                "//tools/rules/vfs_overlay:vfs_overlay",
            ),
            executable = True,
        ),
    },
    outputs = {"vfs_overlay": "%{name}.yaml"},
)
