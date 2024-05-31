
load("//rules:providers.bzl", "VFSInfo")
load("//rules:framework_utils.bzl", "get_framework_files")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

def _compact(args):
    return [item for item in args if item]

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

def vfs_info(
  ctx,
  swiftmodules,
  root_dir,
  extra_search_paths,
  module_map,
  hdrs, 
  private_hdrs):
  return struct(
    vfs_prefix = _vfs_prefix(ctx),
    target_triple = _get_basic_llvm_tripple(ctx),
    swiftmodules = swiftmodules,
    root_dir = root_dir,
    extra_search_paths = extra_search_paths,
    module_map = module_map,
    hdrs = hdrs,
    private_hdrs = private_hdrs,
  )

def _vfs_aspect_impl(target, ctx):
    providers = []
    if not ctx.rule.kind in ["framework_vfs_overlay", "apple_framework_packaging"]:
      return providers

    if VFSInfo not in target:
      info = None

      if ctx.rule.kind == "framework_vfs_overlay":
        info = depset(
          [
            vfs_info(
              ctx = ctx,
              swiftmodules = depset(ctx.rule.attr.swiftmodules),
              root_dir = ctx.rule.attr.framework_name,
              extra_search_paths = ctx.rule.attr.extra_search_paths,
              module_map = depset(ctx.rule.attr.modulemap),
              hdrs = depset(ctx.rule.attr.hdrs),
              private_hdrs = depset(ctx.rule.attr.private_hdrs),
            )
          ],
          transitive=[d[VFSInfo].info for d in ctx.rule.attr.deps if VFSInfo in d]
        )
      if ctx.rule.kind == "apple_framework_packaging":
        framework_files = get_framework_files(ctx, ctx.rule.attr, ctx.rule.attr.deps)
        swiftmodules = _compact([framework_files.outputs.swiftmodule, framework_files.outputs.swiftdoc])
        info = depset(
            [
              vfs_info(
                ctx = ctx,
                swiftmodules = depset(swiftmodules),
                root_dir = ctx.rule.attr.framework_name,
                extra_search_paths = None,
                module_map = depset(framework_files.outputs.modulemaps),
                hdrs = depset(framework_files.outputs.headers),
                private_hdrs = depset(framework_files.outputs.private_headers),
              )
            ],
            transitive=[d[VFSInfo].info for d in ctx.rule.attr.deps if VFSInfo in d]
        )
      if info:
        providers.append(
          VFSInfo(
            info = info,
          )
        )

      #if len(providers):
        #print("VFSInfo for {}:".format(target.label))
        #for p in providers:
        #  print(p)

    return providers

vfs_aspect = aspect(
    implementation = _vfs_aspect_impl,
    attr_aspects = ["deps"],
    fragments = ["apple"],
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)