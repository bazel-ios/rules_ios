load("//rules:providers.bzl", "FrameworkInfo")
load("//rules:features.bzl", "feature_names")

FRAMEWORK_SEARCH_PATH = "/build_bazel_rules_ios/frameworks"

VFSOverlayInfo = provider(
    doc = "Propagates vfs overlays",
    fields = {
        "files": "depset with overlays",
        "vfs_info": "intneral obj",
    },
)

# Make roots for a given framework. For now this is done in starlark for speed
# and incrementality. For imported frameworks, there is additional search paths
# enabled
def _make_root(ctx, framework_name, root_dir, extra_search_paths, module_map, hdrs, private_hdrs, has_swift):
    extra_roots = []
    if extra_search_paths:
        sub_dir = "Headers"

        # Strip the build file path
        base_path = "/".join(ctx.build_file_path.split("/")[:-1])
        rooted_path = base_path + "/" + extra_search_paths + "/" + sub_dir + "/"

        extra_roots = [{
            "type": "file",
            "name": file.path.replace(rooted_path, ""),
            "external-contents": file.path,
        } for file in hdrs]

        extra_roots += [{
            "type": "file",
            "name": framework_name + "/" + file.path.replace(rooted_path, ""),
            "external-contents": file.path,
        } for file in hdrs]

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
        }]

    headers_contents = extra_roots
    headers_contents.extend([
        {
            "type": "file",
            "name": file.basename,
            "external-contents": file.path,
        }
        for file in hdrs
    ])

    headers = []
    if len(headers_contents):
        headers = [{
            "name": "Headers",
            "type": "directory",
            "contents": headers_contents,
        }]

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

    roots = []
    if len(headers) or len(private_headers) or len(modules):
        roots.append({
            "name": root_dir,
            "type": "directory",
            "contents": headers + private_headers + modules,
        })
    if has_swift:
        roots.append(_vfs_swift_module_contents(ctx, framework_name, FRAMEWORK_SEARCH_PATH))

    return roots

def _vfs_swift_module_contents(ctx, framework_name, root_dir):
    # Forumlate the framework's swiftmodule - don't have the swiftmodule when
    # creating with apple_library. Consider removing that codepath to make this
    # and other situations easier
    base_path = "/".join(ctx.build_file_path.split("/")[:-1])
    bin_dir = ctx.bin_dir.path
    rooted_path = bin_dir + "/" + base_path

    # Note: Swift translates the input framework name to this because - is an
    # invalid character in module name
    name = framework_name.replace("-", "_") + ".swiftmodule"
    external_contents = rooted_path + "/" + name
    return {
        "type": "file",
        "name": root_dir + "/" + name,
        "external-contents": external_contents,
    }

def _framework_vfs_overlay_impl(ctx):
    vfsoverlays = []

    # Conditionally collect and pass in the VFS overlay here.
    virtualize_frameworks = feature_names.virtualize_frameworks in ctx.features
    if virtualize_frameworks:
        for dep in ctx.attr.deps:
            if FrameworkInfo in dep:
                vfsoverlays.extend(dep[FrameworkInfo].vfsoverlay_infos)
            if VFSOverlayInfo in dep:
                vfsoverlays.append(dep[VFSOverlayInfo].vfs_info)

    vfs = make_vfsoverlay(
        ctx,
        hdrs = ctx.files.hdrs,
        module_map = ctx.files.modulemap,
        private_hdrs = ctx.files.private_hdrs,
        has_swift = ctx.attr.has_swift,
        merge_vfsoverlays = vfsoverlays,
        output = ctx.outputs.vfsoverlay_file,
        extra_search_paths = ctx.attr.extra_search_paths,
    )

    headers = depset([vfs.vfsoverlay_file])
    cc_info = CcInfo(
        compilation_context = cc_common.create_compilation_context(
            headers = headers,
        ),
    )
    return [
        apple_common.new_objc_provider(),
        cc_info,
        VFSOverlayInfo(
            files = depset([vfs.vfsoverlay_file]),
            vfs_info = vfs.vfs_info,
        ),
    ]

def _merge_vfs_infos(base, vfs_infos):
    for vfs_info in vfs_infos:
        base.update(vfs_info)
    return base

# Internally the "vfs obj" is represented as a dictionary, which is keyed on
# the name of the root. This is an opaque value to consumers
def _make_vfs_info(roots):
    keys = {}
    for root in roots:
        name = root["name"]
        keys[name] = root
    return keys

def make_vfsoverlay(ctx, hdrs, module_map, private_hdrs, has_swift, merge_vfsoverlays = [], extra_search_paths = None, output = None):
    framework_name = ctx.attr.framework_name
    framework_path = "{search_path}/{framework_name}.framework".format(
        search_path = FRAMEWORK_SEARCH_PATH,
        framework_name = framework_name,
    )

    roots = _make_root(ctx, framework_name, framework_path, extra_search_paths, module_map, hdrs, private_hdrs, has_swift)
    vfs_info = _make_vfs_info(roots)
    if len(merge_vfsoverlays) > 0:
        vfs_info = _merge_vfs_infos(vfs_info, merge_vfsoverlays)
        roots = vfs_info.values()

    if output == None:
        return struct(vfsoverlay_file = None, vfs_info = vfs_info)

    # These explicit settings ensure that the VFS actually improves search
    # performance.
    vfsoverlay_object = {
        "version": 0,
        "case-sensitive": True,
        "overlay-relative": False,
        "use-external-names": False,
        "roots": roots,
    }
    vfsoverlay_yaml = struct(**vfsoverlay_object).to_json()
    ctx.actions.write(
        content = vfsoverlay_yaml,
        output = output,
    )

    return struct(vfsoverlay_file = output, vfs_info = vfs_info)

framework_vfs_overlay = rule(
    implementation = _framework_vfs_overlay_impl,
    attrs = {
        "framework_name": attr.string(mandatory = True),
        "extra_search_paths": attr.string(mandatory = False),
        "has_swift": attr.bool(default = False),
        "modulemap": attr.label(allow_single_file = True),
        "hdrs": attr.label_list(allow_files = True),
        "private_hdrs": attr.label_list(allow_files = True, default = []),
        "deps": attr.label_list(allow_files = True, default = []),
    },
    outputs = {
        "vfsoverlay_file": "%{name}.yaml",
    },
)
