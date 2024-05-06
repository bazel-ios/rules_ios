"""framework_vfs_overlay impl

Note on `external-contents` key set many times in this file:

Internal to swift and clang - LLVM `VirtualFileSystem` object can
serialize paths relative to the absolute path of the overlay. This
requires the paths are relative to the overlay. While deriving the
in-memory tree roots, it pre-pends the prefix of the `vfsoverlay` path
to each of the entries.
"""

load("//rules:providers.bzl", "FrameworkInfo")
load("//rules:features.bzl", "feature_names")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_common")

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
    for _ in range(0, length):
        prefix += dots
    return prefix

def _get_vfs_parent(ctx):
    root_path = ctx.bin_dir.path + "/"

    # For an external package, the BUILD file will be rooted relative to the
    # workspace_root, account for this
    if len(ctx.label.workspace_root):
        root_path += ctx.label.workspace_root + "/"
    return root_path + ctx.build_file_path

def _find_top_swiftmodule_file(swiftmodules):
    for file in swiftmodules:
        if file.basename.endswith(".swiftmodule"):
            return file
    return None

# Builds out the VFS subtrees for a given set of paths. This is useful to
# construct an in-memory rep of a tree on the file system
# buildifier: disable=list-append
def _build_subtrees(paths, vfs_prefix):
    # It uses a O(NVFSParts) sized helper dict to avoid O(NPathComponents^2)
    # worst case runtime
    subdirs_json = {"contents": [], "type": "directory", "name": "root"}
    subdirs = struct(dict = {}, json = subdirs_json)
    for path_info in paths:
        path = path_info.framework_path

        # Avoid calling `.split` when possible for better performance
        parts = []
        parts_len = 0
        if "/" in path:
            parts = path.split("/")
            parts_len = len(parts)
        else:
            parts = [path]
            parts_len = 1

        if parts_len == 0:
            fail("[ERROR] Failed to build VFS subtrees, path with empty split on '/': path=%s, parts=%s" % (path, parts))

        # current pointer to the current subdirs while walking the path
        curr_subdirs = subdirs

        # Loop the _framework_ path and add each dir to the current tree.
        # Assume the last bit is a file then add it as a file
        idx = 0

        for part in parts:
            if idx == parts_len - 1:
                curr_subdirs.dict[part] = -1
                curr_subdirs.json["contents"] += [{"name": part, "type": "file", "external-contents": vfs_prefix + path_info.path}]
                break

            # Lookup a value for the current subdirs, otherwise append
            next_subdirs = curr_subdirs.dict[part] if part in curr_subdirs.dict else None
            if not next_subdirs:
                next_subdirs_json = {"contents": [], "type": "directory", "name": part}
                next_subdirs = struct(dict = {}, json = next_subdirs_json)

                curr_subdirs.dict[part] = next_subdirs
                curr_subdirs.json["contents"] += [next_subdirs_json]

            curr_subdirs = next_subdirs
            idx += 1
    return subdirs_json

def _get_private_framework_header(path):
    if "/PrivateHeaders/" not in path:
        return None
    last_parts = path.split("/PrivateHeaders/")
    if len(last_parts) < 2:
        return None
    return last_parts[1]

def _get_public_framework_header(path):
    if "/Headers/" not in path:
        return None
    last_parts = path.split("/Headers/")
    if len(last_parts) < 2:
        return None
    return last_parts[1]

# Make roots for a given framework. For now this is done in starlark for speed
# and incrementality. For imported frameworks, there is additional search paths
# enabled
# buildifier: disable=list-append
def _make_root(vfs_prefix, target_triple, swiftmodules, root_dir, extra_search_paths, module_map, hdrs, private_hdrs):
    private_headers_contents = []
    headers_contents = []

    if extra_search_paths:
        paths = []
        for hdr in hdrs:
            path = hdr.path
            framework_path = _get_public_framework_header(path)
            if not framework_path:
                continue
            paths += [struct(path = hdr.path, framework_path = framework_path)]
        subtrees = _build_subtrees(paths, vfs_prefix)
        headers_contents += subtrees["contents"]

        paths = []
        for hdr in (private_hdrs + hdrs):
            path = hdr.path
            framework_path = _get_private_framework_header(path)
            if not framework_path:
                continue
            paths += [struct(path = hdr.path, framework_path = framework_path)]
        subtrees = _build_subtrees(paths, vfs_prefix)
        private_headers_contents += subtrees["contents"]

    # Swiftmodules: should we factor this  upwards
    modules_contents = []
    if module_map:
        modules_contents += [{
            "type": "file",
            "name": "module.modulemap",
            "external-contents": vfs_prefix + module_map[0].path,
        }]

    if swiftmodules:
        any_swiftmodule_file = swiftmodules[0]
        if any_swiftmodule_file.is_source:
            # Handle a glob of files inside of a .swiftmodule e.g. for xcframework
            parent_dir_base_name = any_swiftmodule_file.dirname.split("/").pop()
            if parent_dir_base_name.endswith(".swiftmodule"):
                modules_contents += [{
                    "type": "directory",
                    "name": parent_dir_base_name,
                    "contents": [
                        {
                            "type": "file",
                            "name": file.basename,
                            "external-contents": vfs_prefix + file.path,
                        }
                        for file in swiftmodules
                    ],
                }]

    modules = []
    if modules_contents:
        modules = [{
            "name": "Modules",
            "type": "directory",
            "contents": modules_contents,
        }]

    # If there isn't an extra search path build the default paths. Perhaps we
    # can build this out if-empty as a followup
    if not extra_search_paths:
        headers_contents += [
            {
                "type": "file",
                "name": file.basename,
                "external-contents": vfs_prefix + file.path,
            }
            for file in hdrs
        ]

    headers = []
    if headers_contents:
        headers = [{
            "name": "Headers",
            "type": "directory",
            "contents": headers_contents,
        }]

    if not extra_search_paths:
        private_headers_contents += [
            {
                "type": "file",
                "name": file.basename,
                "external-contents": vfs_prefix + file.path,
            }
            for file in private_hdrs
        ]

    private_headers = []
    if private_headers_contents:
        private_headers = [{
            "name": "PrivateHeaders",
            "type": "directory",
            "contents": private_headers_contents,
        }]

    roots = []
    if headers or private_headers or modules:
        roots += [{
            "name": root_dir,
            "type": "directory",
            "contents": headers + private_headers + modules,
        }]

    if swiftmodules:
        contents = _provided_vfs_swift_module_contents(swiftmodules, vfs_prefix, target_triple)
        if contents:
            roots += [contents]
    return roots

def _provided_vfs_swift_module_contents(swiftmodules, vfs_prefix, target_triple):
    swiftmodule_file = _find_top_swiftmodule_file(swiftmodules)

    # Note: here we need to import the "top" swiftmodule where the compiler can
    # find it. Followup if it's possible and gainful to present this inside of
    # a framework. User provided directory swiftmodules are presented under
    # frameworks above.
    if swiftmodule_file == None or swiftmodule_file.is_source:
        return None

    contents = [
        {
            "type": "file",
            "name": target_triple + "." + file.extension,
            "external-contents": vfs_prefix + file.path,
        }
        for file in swiftmodules
    ]

    return {
        "type": "directory",
        "name": swiftmodule_file.basename,
        "contents": contents,
    }

def _framework_vfs_overlay_impl(ctx):
    vfsoverlays = []

    # Conditionally collect and pass in the VFS overlay here.
    virtualize_frameworks = feature_names.virtualize_frameworks in ctx.features
    if virtualize_frameworks and not feature_names.compile_with_xcode in ctx.features:
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
        swift_common.create_swift_info(),
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

def _get_basic_llvm_tripple(ctx):
    """Returns a target triple string for an Apple platform.

    Args:
        cpu: The CPU of the target.
        platform: The `apple_platform` value describing the target platform.

    Returns:
        An IDE target triple string describing the platform.
    """
    apple_fragment = ctx.fragments.apple
    platform = apple_fragment.single_arch_platform
    platform_string = str(platform.platform_type)
    if platform_string == "macos":
        platform_string = "macosx"

    cc_toolchain = find_cpp_toolchain(ctx)

    if cc_toolchain.cpu.startswith("darwin_"):
        cpu = cc_toolchain.cpu[len("darwin_"):]
    else:
        cpu = apple_fragment.single_arch_cpu

    environment = ""
    if not platform.is_device:
        environment = "-simulator"

    return "{cpu}-apple-{platform}{environment}".format(
        cpu = cpu,
        environment = environment,
        platform = platform_string,
    )

# Roots must be computed _relative_ to the vfs_parent. It is no longer possible
# to memoize VFS computations because of this.
def _roots_from_datas(vfs_prefix, target_triple, datas):
    return [
        root
        for data in datas
        for root in _make_root(
            vfs_prefix = vfs_prefix,
            target_triple = target_triple,
            root_dir = data.framework_path,
            extra_search_paths = data.extra_search_paths,
            module_map = data.module_map,
            swiftmodules = data.swiftmodules,
            hdrs = data.hdrs,
            private_hdrs = data.private_hdrs,
        )
    ]

def make_vfsoverlay(ctx, hdrs, module_map, private_hdrs, has_swift, swiftmodules = [], merge_vfsoverlays = [], extra_search_paths = None, output = None, framework_name = None):
    if framework_name == None:
        framework_name = ctx.attr.framework_name

    framework_path = "{framework_name}.framework".format(
        framework_name = framework_name,
    )

    vfs_parent = _get_vfs_parent(ctx)
    vfs_parent_len = len(vfs_parent.split("/")) - 1
    vfs_prefix = _make_relative_prefix(vfs_parent_len)

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
    target_triple = _get_basic_llvm_tripple(ctx)

    vfs_info = _make_vfs_info(framework_name, data)
    if merge_vfsoverlays:
        vfs_info = _merge_vfs_infos(vfs_info, merge_vfsoverlays)
        roots = _roots_from_datas(vfs_prefix, target_triple, vfs_info.values())
    else:
        roots = _make_root(
            vfs_prefix = vfs_prefix,
            target_triple = target_triple,
            root_dir = framework_path,
            extra_search_paths = extra_search_paths,
            module_map = module_map,
            swiftmodules = swiftmodules,
            hdrs = hdrs,
            private_hdrs = private_hdrs,
        )

    if output == None:
        return struct(vfsoverlay_file = None, vfs_info = vfs_info)

    vfsoverlay_object = {
        "version": 0,
        "case-sensitive": True,
        "overlay-relative": True,
        "use-external-names": True,
        "roots": [{
            "name": FRAMEWORK_SEARCH_PATH,
            "type": "directory",
            "contents": roots,
        }],
    }
    vfsoverlay_yaml = struct(**vfsoverlay_object).to_json()
    ctx.actions.write(
        content = vfsoverlay_yaml,
        output = output,
    )

    return struct(vfsoverlay_file = output, vfs_info = vfs_info)

framework_vfs_overlay = rule(
    implementation = _framework_vfs_overlay_impl,
    toolchains = use_cpp_toolchain(),
    attrs = {
        "framework_name": attr.string(mandatory = True),
        "extra_search_paths": attr.string(mandatory = False),
        "modulemap": attr.label(allow_single_file = True),
        "has_swift": attr.bool(default = False, doc = "Set to True only if there are Swift source files"),
        "swiftmodules": attr.label_list(allow_files = True, doc = "Everything under a .swiftmodule dir if exists"),
        "hdrs": attr.label_list(allow_files = True),
        "private_hdrs": attr.label_list(allow_files = True, default = []),
        "deps": attr.label_list(allow_files = True, default = []),
        "_cc_toolchain": attr.label(
            providers = [cc_common.CcToolchainInfo],
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
            doc = """\
The C++ toolchain from which linking flags and other tools needed by the Swift
toolchain (such as `clang`) will be retrieved.
""",
        ),
    },
    fragments = [
        "apple",
    ],
    outputs = {
        "vfsoverlay_file": "%{name}.yaml",
    },
)
