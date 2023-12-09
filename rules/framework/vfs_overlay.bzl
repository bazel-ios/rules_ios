"""framework_vfs_overlay impl

Note on `external-contents` key set many times in this file:

Internal to swift and clang - LLVM `VirtualFileSystem` object can
serialize paths relative to the absolute path of the overlay. This
requires the paths are relative to the overlay. While deriving the
in-memory tree roots, it pre-pends the prefix of the `vfsoverlay` path
to each of the entries.
"""

load("//rules/framework:vfs_aspect.bzl", "framework_vfs_aspect", "vfs_node")
load("//rules:providers.bzl", "FrameworkInfo", "NewVFSInfo", "VFSOverlayInfo")
load("//rules:features.bzl", "feature_names")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_common")

FRAMEWORK_SEARCH_PATH = "/build_bazel_rules_ios/frameworks"

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
def _make_root(
        vfs_prefix,
        target_triple,
        swiftmodules,
        root_dir,
        extra_search_paths,
        module_map,
        hdrs,
        private_hdrs,
        force_root_names = {}):
    if root_dir in force_root_names:
        return [{
            "name": root_dir,
            "type": "directory",
            "contents": [],
        }]

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

    foo_uniq = []
    sq_core_dict = {}

    def root_fmw_template(n):
        foo = {
            "name": "%s.framework" % n.framework_name,
            "type": "directory",
            "contents": [
                {
                    "name": "Headers",
                    "type": "directory",
                    "contents": [],
                },
                {
                    "name": "Modules",
                    "type": "directory",
                    "contents": [],
                },
            ],
        }

        return foo

    def root_swiftmodule_template(framework_name):
        return {
            "name": "%s.swiftmodule" % framework_name,
            "type": "directory",
            "contents": [],
        }

    # Uniq from aspect
    visited_hdrs = []
    new_fmw_roots = {}
    calculated_split_bases = {}
    for d in ctx.attr.deps:
        if NewVFSInfo not in d:
            continue
        for n in d[NewVFSInfo].nodes.to_list():
            if n.path in visited_hdrs:
                continue
            if not n.framework_name:
                continue

            visited_hdrs += [n.path]
            is_swiftmodule = n.path.endswith(".swiftmodule") or n.path.endswith(".swiftdoc")

            framework_name_key = None
            if is_swiftmodule:
                framework_name_key = n.framework_name + ".swiftmodule"
            else:
                framework_name_key = n.framework_name + ".framework"

            if not framework_name_key in calculated_split_bases:
                calculated_split_bases[framework_name_key] = []

            fmw_template = {}
            if not framework_name_key in new_fmw_roots:
                if is_swiftmodule:
                    fmw_template = root_swiftmodule_template(n.framework_name)
                else:
                    fmw_template = root_fmw_template(n)
                new_fmw_roots[framework_name_key] = fmw_template
            else:
                fmw_template = new_fmw_roots[framework_name_key]

            if n.path.endswith(".h"):
                has_private_headers = "PrivateHeaders" in [d["name"] for d in fmw_template["contents"]]

                # SPLIT START
                inner_node = None
                outer_node = None
                split_base_calculated = n.split_base in calculated_split_bases[framework_name_key]

                if n.split_base and not split_base_calculated:
                    new_nodes = []
                    splitted = n.split_base_splitted.to_list()
                    for idx in range(0, len(splitted)):
                        dir_name = splitted[idx]
                        new_node = {
                            "name": dir_name,
                            "type": "directory",
                            "contents": [],
                        }
                        new_nodes += [new_node]

                    curr_node = None
                    if new_nodes:
                        for idx in range(len(new_nodes) - 1, -1, -1):
                            split_node_after = new_nodes[idx]
                            if curr_node:
                                split_node_after = curr_node
                            else:
                                inner_node = split_node_after
                            if idx - 1 >= 0:
                                split_node_before = new_nodes[idx - 1]
                                split_node_before["contents"] += [split_node_after]
                                curr_node = split_node_before
                            else:
                                break
                    outer_node = curr_node

                    # set split_base_calculated effectively
                    calculated_split_bases[framework_name_key] += [n.split_base]
                    if not inner_node or not outer_node:
                        fail("missing notes to handle split")

                # SPLIT END

                if not n.is_private_hdrs:
                    for d2 in fmw_template["contents"]:
                        def _find_inner_node(n, d2):
                            ds_list = []
                            for d in n.split_base_splitted.to_list():
                                if not ds_list:
                                    ds_list = [x for x in d2["contents"] if x["name"] == d]
                                else:
                                    for y in ds_list:
                                        ds_list = [x for x in y["contents"] if x["name"] == d]
                                if not len(ds_list):
                                    fail(n)
                            return ds_list[0]

                        def _add_hdr_node(new_node, n, d2):
                            if not n.split_base:
                                d2["contents"] += [new_node]
                                return

                            tmp_root = d2
                            split_base_splitted = n.split_base.split("/")
                            foo_len = len(split_base_splitted)
                            for idx in range(0, foo_len):
                                d = split_base_splitted[idx]
                                should_print = n.path.endswith("wire/package-info.h")
                                tmp_a = [x for x in tmp_root["contents"] if x["name"] == d]
                                if not tmp_a and idx == (foo_len - 1):
                                    new_inner_node = {"name": d, "type": "directory", "contents": [new_node]}
                                    tmp_root["contents"] += [new_inner_node]
                                elif not tmp_a and idx < (foo_len - 1):
                                    new_inner_node = {"name": d, "type": "directory", "contents": []}
                                    tmp_root["contents"] += [new_inner_node]
                                    tmp_root = new_inner_node
                                elif tmp_a and idx == (foo_len - 1):
                                    tmp_root = tmp_a[0]
                                    tmp_root["contents"] += [new_node]
                                elif tmp_a and idx < (foo_len - 1):
                                    tmp_root = tmp_a[0]
                                else:
                                    fail("nope")

                        if d2["name"] == "Headers":
                            if n.path.endswith(".pbobjc.h") or \
                               n.path.endswith("-umbrella.h") or \
                               n.path.endswith("-Swift.h") or \
                               n.path.count("_proto_"):
                                new_node = {
                                    "type": "file",
                                    "name": n.basename,
                                    "external-contents": "../../../../../" + n.path,
                                }

                                _add_hdr_node(new_node, n, d2)
                                # if inner_node and outer_node:
                                #     inner_node["contents"] += [new_node]
                                #     d2["contents"] += [outer_node]
                                # elif n.split_base and not inner_node:
                                #     inner_node = _find_inner_node(n, d2)
                                #     inner_node["contents"] += [new_node]
                                # else:
                                #     d2["contents"] += [new_node]

                            elif not n.is_private_hdrs:
                                new_node = {
                                    "name": n.basename,
                                    "type": "file",
                                    "external-contents": "../../../../../" + n.path,
                                }

                                # if n.basename == "LineItemRuleNode.h":
                                #     print(n.split_base)
                                # print(calculated_split_bases[framework_name_key])

                                # if n.basename == "DiscountHelper.h":
                                #     print(calculated_split_bases[framework_name_key])

                                _add_hdr_node(new_node, n, d2)
                                # if inner_node and outer_node:
                                #     inner_node["contents"] += [new_node]
                                #     d2["contents"] += [outer_node]
                                # elif n.split_base and not inner_node:
                                #     inner_node = _find_inner_node(n, d2)
                                #     inner_node["contents"] += [new_node]
                                # else:
                                #     d2["contents"] += [new_node]

                else:
                    if not has_private_headers:
                        fmw_template["contents"] += [{
                            "name": "PrivateHeaders",
                            "type": "directory",
                            "contents": [],
                        }]
                    for d2 in fmw_template["contents"]:
                        if d2["name"] == "PrivateHeaders":
                            new_node = {
                                "name": n.basename,
                                "type": "file",
                                "external-contents": "../../../../../" + n.og_private_hdr_path if n.og_private_hdr_path else n.path,
                            }

                            _add_hdr_node(new_node, n, d2)
                            # if inner_node and outer_node:
                            #     inner_node["contents"] += [new_node]
                            #     d2["contents"] += [outer_node]
                            # elif n.split_base and not inner_node:
                            #     inner_node = _find_inner_node(n, d2)
                            #     inner_node["contents"] += [new_node]
                            # else:
                            #     d2["contents"] += [new_node]

            elif n.path.endswith(".modulemap"):
                for d2 in fmw_template["contents"]:
                    if d2["name"] == "Modules":
                        # Assign instead of appending to .extended wins
                        d2["contents"] += [{
                            "type": "file",
                            "name": "module.modulemap",
                            "external-contents": "../../../../../" + n.path,
                        }]
                        if len(d2["contents"]) > 1:
                            d2["contents"] = [f for f in d2["contents"] if f["external-contents"].count(".extended.modulemap")]
            elif is_swiftmodule:
                fmw_template["contents"] += [{
                    "name": n.basename,
                    "type": "file",
                    "external-contents": "../../../../../" + n.path,
                }]

            if framework_name_key not in foo_uniq:
                foo_uniq += [framework_name_key]

    force_roots = []
    force_roots += [
        dict(v)
        for (k, v) in new_fmw_roots.items()
    ]
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
        force_roots = force_roots,
    )

    # if ctx.attr.name == "Some_vfs":
    # if len(foo_uniq) == 0:
    #     fail("foo_uniq empty")

    # foo_diff = []
    # for f in vfs.fmw_names:
    #     if f not in foo_uniq:
    #         foo_diff += [f]

    # if foo_diff:
    #     print("diff len: %s" % len(foo_diff))

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
            nodes = vfs.nodes,
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
def _roots_from_datas(vfs_prefix, target_triple, datas, force_root_names = {}):
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
            force_root_names = force_root_names,
        )
    ]

def make_vfsoverlay(
        ctx,
        hdrs,
        module_map,
        private_hdrs,
        has_swift,
        swiftmodules = [],
        merge_vfsoverlays = [],
        extra_search_paths = None,
        output = None,
        framework_name = None,
        merge_nodes = [],
        force_roots = []):
    force_root_names = [f["name"] for f in force_roots]

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
    all_vfs_infos = [vfs_info]
    if merge_vfsoverlays:
        vfs_info = _merge_vfs_infos(vfs_info, merge_vfsoverlays)
        all_vfs_infos = vfs_info.values()
        roots = _roots_from_datas(vfs_prefix, target_triple, all_vfs_infos, force_root_names)
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
            force_root_names = force_root_names,
        )

    # all_hdrs = hdrs + private_hdrs + module_map + swiftmodules
    # No need to propagated private_hdrs due to PrivateHeadersInfo
    # being collected in vfs_aspect (?)
    all_hdrs = hdrs + module_map + swiftmodules

    # for h in all_hdrs:
    #     print(h.path)
    all_nodes = [
        vfs_node(
            ctx,
            h,
            framework_name,
            extra_search_paths,
            target_triple,
        )
        for h in all_hdrs
    ]
    all_transitive_nodes = []
    # all_transitive_nodes += merge_nodes
    # for d in ctx.attr.deps:
    #     if FrameworkInfo in d:
    #         all_transitive_nodes += [d[FrameworkInfo].nodes]
    #     if VFSOverlayInfo in d:
    #         all_transitive_nodes += [d[VFSOverlayInfo].nodes]

    foo_names = []
    for r in roots:
        if r["name"] not in foo_names:
            foo_names += [r["name"]]

    should_print = False
    if should_print:
        print("(%s) foo-1: %s" % (framework_name, len(merge_vfsoverlays)))

    # swiftmodules get in this conditional
    if output == None:
        if should_print:
            print("(%s) foo-2: %s" % (framework_name, len(merge_vfsoverlays)))

        return struct(
            fmw_names = foo_names,
            vfsoverlay_file = None,
            vfs_info = vfs_info,
            nodes = depset(
                all_nodes,
                transitive = all_transitive_nodes,
            ),
        )
    elif should_print:
        print("(%s) foo-3: %s" % (framework_name, len(merge_vfsoverlays)))

    new_roots = []
    all_root_names = [d["name"] for d in roots]
    extra_force_root_names = [f for f in force_root_names if f not in all_root_names]
    new_roots = [f for f in force_roots if f["name"] in extra_force_root_names]

    for d in roots:
        if d["name"] in force_root_names:
            # print("REPLACING: %s" % d["name"])
            tmp_new_root = [f for f in force_roots if f["name"] == d["name"]]
            tmp_new_root = tmp_new_root[0]
            new_roots += [tmp_new_root]
        else:
            new_roots += [d]

    vfsoverlay_object = {
        "version": 0,
        "case-sensitive": True,
        "overlay-relative": True,
        "use-external-names": True,
        "roots": [{
            "name": FRAMEWORK_SEARCH_PATH,
            "type": "directory",
            "contents": new_roots,
        }],
    }

    vfsoverlay_yaml = struct(**vfsoverlay_object).to_json()
    ctx.actions.write(
        content = vfsoverlay_yaml,
        output = output,
    )

    return struct(
        fmw_names = foo_names,
        vfsoverlay_file = output,
        vfs_info = vfs_info,
        nodes = depset(
            all_nodes,
            transitive = all_transitive_nodes,
        ),
    )

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
        # "deps": attr.label_list(allow_files = True, default = [], aspects = [framework_vfs_aspect]),
        "deps": attr.label_list(allow_files = True, default = [], aspects = [framework_vfs_aspect]),
        "_cc_toolchain": attr.label(
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
