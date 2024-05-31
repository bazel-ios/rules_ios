load("//rules:providers.bzl", "VFSInfo")

def _vfs_aspect_impl(target, ctx):
    providers = []

    if VFSInfo not in target:
      providers.append(
        VFSInfo(
          vfs_prefix = "foo",
          target_triple = "foo",
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
)