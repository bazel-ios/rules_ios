load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@build_bazel_rules_swift//swift/internal:compiling.bzl", "precompile_clang_module")
load("@build_bazel_rules_swift//swift/internal:feature_names.bzl", "SWIFT_FEATURE_SYSTEM_MODULE")
load(
    "@build_bazel_rules_swift//swift/internal:providers.bzl",
    "SwiftInfo",
    "SwiftToolchainInfo",
    "create_clang_module",
    "create_module",
    "create_swift_info",
)
load("@build_bazel_rules_swift//swift/internal:swift_common.bzl", "swift_common")
load(
    "@build_bazel_rules_swift//swift/internal:utils.bzl",
    "compilation_context_for_explicit_module_compilation",
    "get_providers",
)

def _sdk_clang_module_impl(ctx):
    compilation_context = cc_common.create_compilation_context()
    compilation_context_to_compile = (
        compilation_context_for_explicit_module_compilation(
            compilation_contexts = (
                [compilation_context]
            ),
            deps = ctx.attr.deps,
        )
    )

    swift_toolchain = ctx.attr._toolchain[SwiftToolchainInfo]
    requested_features = ctx.features + [SWIFT_FEATURE_SYSTEM_MODULE]
    feature_configuration = swift_common.configure_features(
        ctx = ctx,
        requested_features = requested_features,
        swift_toolchain = swift_toolchain,
        unsupported_features = ctx.disabled_features,
    )

    swift_infos = get_providers(ctx.attr.deps, SwiftInfo)

    precompiled_module = precompile_clang_module(
        actions = ctx.actions,
        cc_compilation_context = compilation_context_to_compile,
        feature_configuration = feature_configuration,
        module_map_file = ctx.attr.module_map,
        module_name = ctx.attr.module_name,
        swift_infos = swift_infos,
        swift_toolchain = swift_toolchain,
        target_name = ctx.attr.name,
    )

    return [
        create_swift_info(
            modules = [
                create_module(
                    name = ctx.attr.module_name,
                    clang = create_clang_module(
                        compilation_context = compilation_context,
                        module_map = ctx.attr.module_map,
                        precompiled_module = precompiled_module,
                    ),
                ),
            ],
            swift_infos = swift_infos,
        ),
        OutputGroupInfo(
            swift_explicit_module = depset([precompiled_module]),
        ),
    ]

sdk_clang_module = rule(
    implementation = _sdk_clang_module_impl,
    fragments = ["cpp"],
    attrs = dicts.add(
        swift_common.toolchain_attrs(),
        {
            "deps": attr.label_list(
                doc = "The deps of the SDK clang module",
                providers = [[SwiftInfo]],
            ),
            "module_map": attr.string(
                doc = """\
    The path to a SDK framework module map.
    Variables `__BAZEL_XCODE_SDKROOT__` and `__BAZEL_XCODE_DEVELOPER_DIR__` will be substitued
    appropriately for, i.e.  
    `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk`
    and
    `/Applications/Xcode.app/Contents/Developer` respectively.
    """,
                mandatory = True,
            ),
            "module_name": attr.string(
                doc = """\
    The name of the top-level module in the module map that this target represents.
    """,
                mandatory = True,
            ),
        },
    ),
    doc = """\
A rule representing a SDK clang module. It's required for explicit module builds.
""",
)
