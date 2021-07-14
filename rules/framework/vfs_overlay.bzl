load("//rules:internal.bzl", "FrameworkInfo")

FRAMEWORK_SEARCH_PATH = "/build_bazel_rules_ios/frameworks"

VFSOverlayInfo = provider(
    doc = "Propagates vfs overlays",
    fields = {
        "files": "depset with overlays",
        "merged_files": "depset with overlays",
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

def _extra_vfs_root(ctx, framework_name, root_dir, extra_vfs_root, module_map, hdrs, private_hdrs, has_swift):
    extra_roots = []
    filtered_hdrs = hdrs
    if extra_vfs_root:
        sub_dir = "Headers"

        # Strip the build file path
        base_path = "/".join(ctx.build_file_path.split("/")[:-1])
        rooted_path = base_path + "/" + extra_vfs_root + "/" + sub_dir + "/"
        extra_roots = [
            {
                "type": "file",
                "name": file.path.replace(rooted_path, ""),
                "external-contents": file.path,
            }
            for file in filtered_hdrs
        ]
        extra_roots += [
            {
                "type": "file",
                "name": framework_name + "/" + file.path.replace(rooted_path, ""),
                "external-contents": file.path,
            }
            for file in filtered_hdrs
        ]

    modules_contents = []
    if len(module_map):
        modules_contents.append({
            "type": "file",
            "name": "module.modulemap",
            "external-contents": module_map[0].path,
        })

    modules = []
    if len(modules_contents):
        modules = [{
            "name": "Modules",
            "type": "directory",
            "contents": modules_contents,
            # Note: this is currently not working
            # [_vfs_swift_module_header_contents(ctx, vfs_name)]
        }]

    headers = [{
        "name": "Headers",
        "type": "directory",
        "contents": [
            {
                "type": "file",
                "name": file.basename,
                "external-contents": file.path,
            }
            for file in filtered_hdrs
        ] + extra_roots,
    }]

    # Note: we shouldn't propagate these private headers - it's happening throuugh merging
    private_headers_contents = {
        "name": "PrivateHeaders",
        "type": "directory",
        "contents": [
            {
                "type": "file",
                "name": file.basename,
                "external-contents": file.path,
            }
            for file in private_hdrs
        ],
    }

    private_headers = []
    if len(private_hdrs):
        private_headers = [private_headers_contents]

    ret = [{
        "name": root_dir,
        "type": "directory",
        "contents": headers + private_headers + modules,
    }]
    if has_swift:
        ret += [_vfs_swift_module_header_contents(ctx, framework_name, "/build_bazel_rules_ios/frameworks/")]

    return ret

# CAN REMOVE
def _vfs_swift_header_contents(ctx, framework_name):
    bin_dir = ctx.bin_dir.path
    base_path = "/".join(ctx.build_file_path.split("/")[:-1])
    fw_name = framework_name
    rooted_path = bin_dir + "/" + base_path
    h_name = fw_name + "-Swift.h"
    external_contents = rooted_path + "/" + h_name
    return {
        "type": "file",
        "name": h_name,
        "external-contents": external_contents,
    }

# Consider passing this instead
def _vfs_swift_module_header_contents(ctx, framework_name, root = ""):
    fw_name = framework_name
    bin_dir = ctx.bin_dir.path
    base_path = "/".join(ctx.build_file_path.split("/")[:-1])
    rooted_path = bin_dir + "/" + base_path
    h_name = fw_name + ".swiftmodule"
    external_contents = rooted_path + "/" + h_name

    # Note: We can put these directly at the root
    return {
        "type": "file",
        "name": root + h_name,
        "external-contents": external_contents,
    }

    return {
        "name": root + h_name,
        "type": "directory",
        "contents": [{
            "type": "file",
            "name": "x86_64.swiftmodule",
            "external-contents": external_contents,
        }],
    }

def _framework_vfs_overlay_impl(ctx):
    vfsoverlays = []
    for dep in ctx.attr.deps:
        if FrameworkInfo in dep:
            framework_info = dep[FrameworkInfo]
            vfsoverlays.append(framework_info.vfsoverlay_infos)
        if VFSOverlayInfo in dep:
            vfsoverlays.append(dep[VFSOverlayInfo].files)

    vfs_ret = write_vfs(
        ctx,
        hdrs = ctx.files.hdrs,
        module_map = ctx.files.modulemap,
        private_hdrs = ctx.files.private_hdrs,
        has_swift = ctx.attr.has_swift,
        vfs_providers = [],
        merge_vfsoverlays = vfsoverlays,
        vfsoverlay_file = ctx.outputs.vfs_overlay,
        merge_tool = ctx.attr.merge_tool,
        extra_vfs_root = ctx.attr.extra_vfs_root,
    )

    headers = depset([vfs_ret.vfsoverlay_file, vfs_ret.vfsoverlay_file_merged], transitive = vfs_ret.vfsoverlays)
    cc_info = CcInfo(
        compilation_context = cc_common.create_compilation_context(
            headers = headers,
        ),
    )
    return [
        apple_common.new_objc_provider(),
        cc_info,
        VFSOverlayInfo(
            files = depset([vfs_ret.vfsoverlay_file]),
            merged_files = depset([vfs_ret.vfsoverlay_file_merged], transitive = vfs_ret.vfsoverlays),
        ),

        # Mainly a debugging mechanism
        OutputGroupInfo(
            vfs = depset([vfs_ret.vfsoverlay_file, vfs_ret.vfsoverlay_file_merged], transitive = vfs_ret.vfsoverlays),
        ),
    ]

# Note: maybe we can put swiftmodules in modules...
def write_vfs(ctx, hdrs, module_map, private_hdrs, has_swift, vfs_providers, vfsoverlay_file, merge_tool, merge_vfsoverlays = [], extra_vfs_root = None):
    framework_path = "{search_path}/{framework_name}.framework".format(
        search_path = FRAMEWORK_SEARCH_PATH,
        framework_name = ctx.attr.framework_name,
    )
    root_dir = framework_path
    roots = _extra_vfs_root(ctx, ctx.attr.framework_name, root_dir, extra_vfs_root, module_map, hdrs, private_hdrs, has_swift)

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

    ctx.actions.write(
        content = vfsoverlay_yaml,
        output = vfsoverlay_file,
    )

    #all_vfs = depset(transitive=merge_vfsoverlays)
    # NEEDED WHEN:
    # Frameworks/SquareCartBuilding/Sources/UI/Other/RQAbstractLineItemsViewController.m
    # all_vfs = depset(transitive=[depset([vfsoverlay_file])] + merge_vfsoverlays)
    all_vfs = depset(transitive = [depset([vfsoverlay_file])] + merge_vfsoverlays)

    vfs_paths = [f.path for f in all_vfs.to_list()]

    # Note: we don't merge the top level VFS here, so we need to propagate the tuple
    merged_output = ctx.actions.declare_file(ctx.attr.name + ".yaml.merged")

    if len(vfs_paths) > 0:
        ctx.actions.run(
            mnemonic = "MergeVFS",
            arguments = [merged_output.path] + vfs_paths,
            inputs = all_vfs,
            executable = merge_tool.files.to_list()[0],
            outputs = [merged_output],
        )
    else:
        evfs = {
            "version": 0,
            "case-sensitive": True,
            "overlay-relative": False,
            "use-external-names": False,
            "roots": [],
        }
        e_vfsoverlay_yaml = struct(**evfs).to_json()
        ctx.actions.write(
            content = e_vfsoverlay_yaml,
            output = merged_output,
        )

    return struct(vfsoverlay_file_merged = merged_output, vfsoverlay_file = vfsoverlay_file, vfsoverlays = [])

framework_vfs_overlay = rule(
    implementation = _framework_vfs_overlay_impl,
    attrs = {
        "framework_name": attr.string(mandatory = True),
        #"framework_imports": attr.string_list(default = []),
        "extra_vfs_root": attr.string(mandatory = False),
        "has_swift": attr.bool(default = False),
        "modulemap": attr.label(allow_single_file = True),
        "hdrs": attr.label_list(allow_files = True),
        "private_hdrs": attr.label_list(allow_files = True),
        "deps": attr.label_list(allow_files = True),
        "merge_tool": attr.label(executable = True, default = Label("//rules/framework:merge_vfs_overlay"), cfg = "host"),
    },
    outputs = {
        "vfs_overlay": "%{name}.yaml",
    },
)
