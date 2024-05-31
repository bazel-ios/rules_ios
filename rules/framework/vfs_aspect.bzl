load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("//rules:providers.bzl", "VFSInfo")

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

def _get_vfs_parent(ctx):
    root_path = ctx.bin_dir.path + "/"

    # For an external package, the BUILD file will be rooted relative to the
    # workspace_root, account for this
    if len(ctx.label.workspace_root):
        root_path += ctx.label.workspace_root + "/"
    return root_path + ctx.build_file_path

def _make_relative_prefix(length):
    dots = "../"
    prefix = ""
    for _ in range(0, length):
        prefix += dots
    return prefix

def _vfs_prefix(ctx):
  vfs_parent = _get_vfs_parent(ctx)
  vfs_parent_len = len(vfs_parent.split("/")) - 1
  return _make_relative_prefix(vfs_parent_len)

def _vfs_aspect_impl(target, ctx):
    providers = []

    if VFSInfo not in target:

      providers.append(
        VFSInfo(
          vfs_prefix = _vfs_prefix(ctx),
          target_triple = _get_basic_llvm_tripple(ctx),
          swiftmodules = "foo",
          root_dir = "foo",
          extra_search_paths = "foo",
          module_map = "foo",
          hdrs = "foo",
          private_hdrs = "foo",
        ),
      )

    return providers

vfs_aspect = aspect(
    implementation = _vfs_aspect_impl,
    attr_aspects = ["deps"],
    fragments = ["apple"],
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)