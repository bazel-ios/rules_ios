load("@build_bazel_rules_swift//swift/internal:swift_common.bzl", "swift_common")
load("@build_bazel_rules_swift//swift/internal:attrs.bzl", "swift_library_rule_attrs")
load("@build_bazel_rules_swift//swift/internal:providers.bzl", "SwiftInfo", "SwiftToolchainInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:dicts.bzl", "dicts")

def _impl(ctx):
    swift_toolchain = ctx.attr._toolchain[SwiftToolchainInfo]

    deps = ctx.attr.deps
    cc_infos = [dep[CcInfo] for dep in deps]
    swift_infos = [dep[SwiftInfo] for dep in deps]

    if cc_infos:
        cc_info = cc_common.merge_cc_infos(cc_infos = cc_infos)
        compilation_context = cc_info.compilation_context
    else:
        cc_info = None
        compilation_context = cc_common.create_compilation_context()

    feature_configuration = swift_common.configure_features(
        ctx = ctx,
        requested_features = ctx.features,
        swift_toolchain = swift_toolchain,
    )

    module_map = paths.join(apple_common.apple_toolchain().developer_dir(), ctx.attr.module_map_file)
    precompiled_module = swift_common.precompile_clang_module(
        actions = ctx.actions,
        cc_compilation_context = compilation_context,
        module_map_file = module_map,
        module_name = ctx.attr.name,
        target_name = ctx.attr.name,
        swift_toolchain = swift_toolchain,
        feature_configuration = feature_configuration,
        swift_infos = swift_infos,
    )
    module = swift_common.create_clang_module(
        compilation_context = compilation_context,
        module_map = module_map,
        precompiled_module = precompiled_module,
    )
    modules = [swift_common.create_module(clang = module, name = ctx.attr.name)]

    return [
        swift_common.create_swift_info(
            modules = modules,
            swift_infos = swift_infos,
        ),
        CcInfo(
            compilation_context = compilation_context,
        ),
    ]

apple_framework_pcm = rule(
    implementation = _impl,
    attrs = dicts.add(
        swift_library_rule_attrs(requires_srcs = False),
        {
            "module_map_file": attr.string(),
        },
    ),
    fragments = ["cpp"],
)
