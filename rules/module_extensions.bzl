"""Definitions for bzlmod module extensions."""

load(
    "//rules:repositories.bzl",
    "rules_ios_dependencies",
    "rules_ios_dev_dependencies",
)
load(
    "//tools/toolchains/xcode_configure:xcode_configure.bzl",
    _xcode_configure = "xcode_configure",
)
load("@bazel_features//:features.bzl", "bazel_features")


def _non_module_deps_impl(module_ctx):
    rules_ios_dependencies(
        load_bzlmod_dependencies = False,
    )
    metadata_kwargs = {}
    if bazel_features.external_deps.extension_metadata_has_reproducible:
        metadata_kwargs["reproducible"] = True

    return module_ctx.extension_metadata(
        **metadata_kwargs
    )


non_module_deps = module_extension(implementation = _non_module_deps_impl)

def _non_module_dev_deps_impl(_):
    rules_ios_dev_dependencies(load_bzlmod_dependencies = False)

non_module_dev_deps = module_extension(implementation = _non_module_dev_deps_impl)

def _xcode_configure_impl(module_ctx):
    for mod in module_ctx.modules:
        for xcode_configure_attr in mod.tags.configure:
            _xcode_configure(
                remote_xcode_label = xcode_configure_attr.remote_xcode_label,
                xcode_locator_label = xcode_configure_attr.xcode_locator_label,
            )

xcode_configure = module_extension(
    implementation = _xcode_configure_impl,
    tag_classes = {
        "configure": tag_class(
            attrs = {
                "remote_xcode_label": attr.string(mandatory = True),
                "xcode_locator_label": attr.string(mandatory = True),
            },
        ),
    },
)
