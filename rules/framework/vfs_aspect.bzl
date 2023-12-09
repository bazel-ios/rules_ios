load("//rules:providers.bzl", "FrameworkInfo", "NewVFSInfo", "PrivateHeadersInfo", "VFSOverlayInfo")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@bazel_skylib//lib:paths.bzl", "paths")

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

def vfs_node(
        ctx,
        hdr,
        framework_name,
        extra_search_paths,
        target_triple,
        is_private_hdrs = False,
        og_private_hdr_path = None):
    hdr_is_str = type(hdr) == "string"
    hdr_path = hdr.short_path if not hdr_is_str else hdr
    split_base = None

    if "Headers" in hdr_path:
        idx = hdr_path.index("Headers")
        split_base = paths.dirname(hdr_path[idx + 8:])
    elif "PrivateHeaders" in hdr_path:
        idx = hdr_path.index("PrivateHeaders")
        split_base = paths.dirname(hdr_path[idx + 15:])

    is_swiftmodule = False
    if hdr_is_str:
        is_swiftmodule = paths.basename(hdr).endswith(".swiftmodule") or paths.basename(hdr).endswith(".swiftdoc")
    else:
        is_swiftmodule = hdr.basename.endswith(".swiftmodule") or hdr.basename.endswith(".swiftdoc")

    final_basename = None
    if hdr_is_str:
        final_basename = paths.basename(hdr) if not is_swiftmodule else (target_triple + "." + paths.split_extension(hdr)[1])
    else:
        final_basename = hdr.basename if not is_swiftmodule else (target_triple + "." + hdr.extension)

    final_hdr_path = hdr.path if not hdr_is_str else hdr

    return struct(
        path = final_hdr_path,
        basename = final_basename,
        type = "file",
        external_contents = hdr.path if not hdr_is_str else hdr,
        dirname = hdr.dirname if not hdr_is_str else paths.dirname(hdr),
        split_base = split_base,
        split_base_splitted = depset(split_base.split("/") if split_base else []),
        framework_name = framework_name,
        extra_search_paths = extra_search_paths,
        is_private_hdrs = is_private_hdrs,
        og_private_hdr_path = og_private_hdr_path,
    )

def _framework_vfs_aspect_impl(target, ctx):
    # Sometime is None, but still needed to match all collecteds hdrs
    framework_name = getattr(ctx.rule.attr, "framework_name", None)
    extra_search_paths = getattr(ctx.rule.attr, "extra_search_paths", None)
    target_tripple = _get_basic_llvm_tripple(ctx)
    namespace = getattr(ctx.rule.attr, "namespace", None)
    if not framework_name and ctx.rule.kind == "headermap":
        # headermap rule
        framework_name = namespace

    hdrs = getattr(ctx.rule.files, "hdrs", [])

    # Might not be needed due to PrivateHeadersInfo below
    # private_hdrs = getattr(ctx.rule.files, "private_hdrs", [])
    module_map = getattr(ctx.rule.files, "modulemap", [])
    swiftmodules = getattr(ctx.rule.files, "swiftmodules", [])

    all_transitive_nodes = []

    # Maybe will come from running the aspect in the framework.bzl class
    merge_nodes = []
    all_transitive_nodes += merge_nodes

    more_private_hdrs = []
    if hasattr(ctx.rule.attr, "deps"):
        for d in ctx.rule.attr.deps:
            if PrivateHeadersInfo in d:
                more_private_hdrs += d[PrivateHeadersInfo].headers.to_list()
            if FrameworkInfo in d:
                all_transitive_nodes += [d[FrameworkInfo].nodes]
            if VFSOverlayInfo in d:
                all_transitive_nodes += [d[VFSOverlayInfo].nodes]
            if NewVFSInfo in d:
                all_transitive_nodes += [d[NewVFSInfo].nodes]

    if hasattr(ctx.rule.attr, "transitive_deps"):
        for d in ctx.rule.attr.transitive_deps:
            if FrameworkInfo in d:
                all_transitive_nodes += [d[FrameworkInfo].nodes]
            if VFSOverlayInfo in d:
                all_transitive_nodes += [d[VFSOverlayInfo].nodes]
            if NewVFSInfo in d:
                all_transitive_nodes += [d[NewVFSInfo].nodes]

    if hasattr(ctx.rule.attr, "vfs"):
        for d in ctx.rule.attr.vfs:
            if FrameworkInfo in d:
                all_transitive_nodes += [d[FrameworkInfo].nodes]
            if VFSOverlayInfo in d:
                all_transitive_nodes += [d[VFSOverlayInfo].nodes]
            if NewVFSInfo in d:
                all_transitive_nodes += [d[NewVFSInfo].nodes]

    if more_private_hdrs:
        if hasattr(ctx.rule.attr, "name") and \
           hasattr(ctx.rule.attr, "framework_name") and \
           hasattr(ctx.rule.attr, "bundle_extension"):
            framework_dir = "%s/%s.%s" % (
                ctx.rule.attr.name,
                ctx.rule.attr.framework_name,
                ctx.rule.attr.bundle_extension,
            )

            more_private_hdrs = [
                (paths.join(framework_dir, "PrivateHeaders", h.basename), h.path)
                for h in more_private_hdrs
            ]

            all_transitive_nodes += [depset([
                vfs_node(
                    ctx,
                    h,
                    framework_name,
                    extra_search_paths,
                    target_tripple,
                    True,
                    og_h,
                )
                for (h, og_h) in more_private_hdrs
            ])]

    all_hdrs = hdrs + module_map + swiftmodules
    all_hdrs = [h for h in all_hdrs if not h.path.count("SQCurrency_Testing")]
    foo = [h.path for h in all_hdrs if h.path.count("SQCurrency_Testing")]
    if foo:
        print(foo)

    all_nodes = [
        vfs_node(
            ctx,
            h,
            framework_name,
            extra_search_paths,
            target_tripple,
        )
        for h in all_hdrs
    ]
    # Not needed due to PrivateHeadersInfo below?
    # all_nodes += [
    #     vfs_node(
    #         ctx,
    #         h,
    #         framework_name,
    #         extra_search_paths,
    #         target_tripple,
    #         True,
    #     )
    #     for h in private_hdrs
    # ]

    return [
        NewVFSInfo(
            nodes = depset(
                all_nodes,
                transitive = all_transitive_nodes,
            ),
        ),
    ]

framework_vfs_aspect = aspect(
    implementation = _framework_vfs_aspect_impl,
    attr_aspects = ["deps", "transitive_deps", "vfs"],
    attrs = {
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
    doc = """
lol
""",
)
