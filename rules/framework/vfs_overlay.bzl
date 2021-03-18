FRAMEWORK_SEARCH_PATH = "/build_bazel_rules_ios/frameworks"

VFSOverlayInfo = provider(
    doc = "Propagates vfs overlays",
    fields = {
        "files": "depset with overlays",
    },
)

def _vfs_root(root_dir, files, override_name = None):
    if not files:
        return

    return {
        "name": root_dir,
        "type": "directory",
        "contents": [
            {
                "type": "file",
                "name": override_name or file.basename,
                "external-contents": file.path,
            }
            for file in files
        ],
    }

def _framework_vfs_overlay_impl(ctx):
    framework_path = "{search_path}/{framework_name}.framework".format(
        search_path = FRAMEWORK_SEARCH_PATH,
        framework_name = ctx.attr.framework_name,
    )

    roots = [
        _vfs_root(root_dir = framework_path + "/Headers", files = ctx.files.hdrs),
        _vfs_root(root_dir = framework_path + "/PrivateHeaders", files = ctx.files.private_hdrs),
        _vfs_root(root_dir = framework_path + "/Modules", files = ctx.files.modulemap, override_name = "module.modulemap"),
    ]

    # These explicit settings ensure that the VFS actually improves search
    # performance.
    vfsoverlay_object = {
        "version": 0,
        "case-sensitive": True,
        "overlay-relative": False,
        "use-external-names": False,
        "roots": [root for root in roots if root],
    }
    vfsoverlay_yaml = struct(**vfsoverlay_object).to_json()
    vfsoverlay_file = ctx.outputs.vfs_overlay

    ctx.actions.write(
        content = vfsoverlay_yaml,
        output = vfsoverlay_file,
    )

    files = depset(direct = [vfsoverlay_file])
    cc_info = CcInfo(
        compilation_context = cc_common.create_compilation_context(
            headers = files,
        ),
    )
    return [
        apple_common.new_objc_provider(),
        cc_info,
        VFSOverlayInfo(
            files = files,
        ),
    ]

framework_vfs_overlay = rule(
    implementation = _framework_vfs_overlay_impl,
    attrs = {
        "framework_name": attr.string(mandatory = True),
        "modulemap": attr.label(allow_single_file = True),
        "hdrs": attr.label_list(allow_files = True),
        "private_hdrs": attr.label_list(allow_files = True),
    },
    outputs = {
        "vfs_overlay": "%{name}.yaml",
    },
)
