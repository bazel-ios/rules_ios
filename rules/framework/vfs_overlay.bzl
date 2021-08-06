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

# Computes the "back" segment for a path length
def _make_relative_prefix(length):
    dots = "../"
    prefix = ""
    for i in range(0, length):
        prefix += dots
    return prefix

# Internal to swift and clang - LLVM `VirtualFileSystem` object can
# serialize paths relative to the absolute path of the overlay. This
# requires the paths are relative to the overlay. While deriving the
# in-memory tree roots, it pre-pends the prefix of the `vfsoverlay` path
# to each of the entries.
def _get_external_contents(prefix, path_str):
    return prefix + path_str

def _get_vfs_parent(ctx):
    return (ctx.bin_dir.path + "/" + ctx.build_file_path)

# Make roots for a given framework. For now this is done in starlark for speed
# and incrementality. For imported frameworks, there is additional search paths
# enabled
def _make_root(vfs_parent, bin_dir_path, build_file_path, framework_name, swiftmodules, root_dir, extra_search_paths, module_map, hdrs, private_hdrs, has_swift):
    vfs_prefix = _make_relative_prefix(len(vfs_parent.split("/")) - 1)
    extra_roots = []
    if extra_search_paths:
        sub_dir = "Headers"

        # Strip the build file path
        base_path = "/".join(build_file_path.split("/")[:-1])
        rooted_path = base_path + "/" + extra_search_paths + "/" + sub_dir + "/"

        extra_roots = [{
            "type": "file",
            "name": file.path.replace(rooted_path, ""),
            "external-contents": _get_external_contents(vfs_prefix, file.path),
        } for file in hdrs]

        extra_roots += [{
            "type": "file",
            "name": framework_name + "/" + file.path.replace(rooted_path, ""),
            "external-contents": _get_external_contents(vfs_prefix, file.path),
        } for file in hdrs]

    modules_contents = []
    if len(module_map):
        modules_contents.append({
            "type": "file",
            "name": "module.modulemap",
            "external-contents": _get_external_contents(vfs_prefix, module_map[0].path),
        })

    if len(swiftmodules):
        # Assuming each swift module content share the same parent
        parent_dir_base_name = swiftmodules[0].dirname.split("/").pop()
        modules_contents.append({
            "type": "directory",
            "name": parent_dir_base_name,
            "contents": [
                {
                    "type": "file",
                    "name": file.basename,
                    "external-contents": _get_external_contents(vfs_prefix, file.path),
                }
                for file in swiftmodules
            ],
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
            "external-contents": _get_external_contents(vfs_prefix, file.path),
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
                "external-contents": _get_external_contents(vfs_prefix, file.path),
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
        roots.append(_vfs_swift_module_contents(bin_dir_path, build_file_path, vfs_prefix, framework_name, FRAMEWORK_SEARCH_PATH))

    return roots

def _vfs_swift_module_contents(bin_dir_path, build_file_path, vfs_prefix, framework_name, root_dir):
    # Forumlate the framework's swiftmodule - don't have the swiftmodule when
    # creating with apple_library. Consider removing that codepath to make this
    # and other situations easier
    base_path = "/".join(build_file_path.split("/")[:-1])
    rooted_path = bin_dir_path + "/" + base_path

    # Note: Swift translates the input framework name to this because - is an
    # invalid character in module name
    name = framework_name.replace("-", "_") + ".swiftmodule"
    external_contents = rooted_path + "/" + name
    return {
        "type": "file",
        "name": root_dir + "/" + name,
        "external-contents": _get_external_contents(vfs_prefix, external_contents),
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
        swiftmodules = ctx.files.swiftmodules,
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
def _make_vfs_info(name, data):
    keys = {}
    keys[name] = data
    return keys

# Roots must be computed _relative_ to the vfs_parent. It is no longer possible
# to memoize VFS computations because of this.
def _roots_from_datas(vfs_parent, datas):
    roots = []
    for data in datas:
        roots.extend(_make_root(
            vfs_parent = vfs_parent,
            bin_dir_path = data.bin_dir_path,
            build_file_path = data.build_file_path,
            framework_name = data.framework_name,
            root_dir = data.framework_path,
            extra_search_paths = data.extra_search_paths,
            module_map = data.module_map,
            swiftmodules = data.swiftmodules,
            hdrs = data.hdrs,
            private_hdrs = data.private_hdrs,
            has_swift = data.has_swift,
        ))
    return roots

def make_vfsoverlay(ctx, hdrs, module_map, private_hdrs, has_swift, swiftmodules = [], merge_vfsoverlays = [], extra_search_paths = None, output = None):
    framework_name = ctx.attr.framework_name
    framework_path = "{search_path}/{framework_name}.framework".format(
        search_path = FRAMEWORK_SEARCH_PATH,
        framework_name = framework_name,
    )

    vfs_parent = _get_vfs_parent(ctx)

    data = struct(
        bin_dir_path = ctx.bin_dir.path,
        build_file_path = ctx.build_file_path,
        framework_name = framework_name,
        framework_path = framework_path,
        extra_search_paths = extra_search_paths,
        module_map = module_map,
        swiftmodules = swiftmodules,
        hdrs = hdrs,
        private_hdrs = private_hdrs,
        has_swift = has_swift,
    )

    roots = _make_root(
        vfs_parent,
        bin_dir_path = ctx.bin_dir.path,
        build_file_path = ctx.build_file_path,
        framework_name = framework_name,
        root_dir = framework_path,
        extra_search_paths = extra_search_paths,
        module_map = module_map,
        swiftmodules = swiftmodules,
        hdrs = hdrs,
        private_hdrs = private_hdrs,
        has_swift = has_swift,
    )

    vfs_info = _make_vfs_info(framework_name, data)
    if len(merge_vfsoverlays) > 0:
        vfs_info = _merge_vfs_infos(vfs_info, merge_vfsoverlays)
        roots = _roots_from_datas(vfs_parent, vfs_info.values() + [data])

    if output == None:
        return struct(vfsoverlay_file = None, vfs_info = vfs_info)

    vfsoverlay_object = {
        "version": 0,
        "case-sensitive": True,
        "overlay-relative": True,
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
        "modulemap": attr.label(allow_single_file = True),
        "has_swift": attr.bool(default = False, doc = "Set to True only if there are Swift source files"),
        "swiftmodules": attr.label_list(allow_files = True, doc = "Everything under a .swiftmodule dir if exists"),
        "hdrs": attr.label_list(allow_files = True),
        "private_hdrs": attr.label_list(allow_files = True, default = []),
        "deps": attr.label_list(allow_files = True, default = []),
    },
    outputs = {
        "vfsoverlay_file": "%{name}.yaml",
    },
)
