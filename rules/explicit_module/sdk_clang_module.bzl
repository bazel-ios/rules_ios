load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@build_bazel_rules_swift//swift/internal:actions.bzl", "swift_action_names")
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
load("@build_bazel_rules_swift//swift/internal:toolchain_config.bzl", "swift_toolchain_config")
load(
    "@build_bazel_rules_swift//swift/internal:utils.bzl",
    "compilation_context_for_explicit_module_compilation",
    "get_providers",
)

def _config_swift_toolchain(ctx):
    """A hack to pass additional flags into swiftc to create a hermetic PCM

    See https://reviews.llvm.org/D124874
    FIXME: Adds the flag in rules_swift.

    args:
        ctx: the context
    return: a SwiftToolchainInfo
    """

    base_wift_toolchain = ctx.attr._toolchain[SwiftToolchainInfo]
    action_configs = base_wift_toolchain.action_configs + [
        swift_toolchain_config.action_config(
            actions = [
                swift_action_names.PRECOMPILE_C_MODULE,
            ],
            configurators = [
                # Embed all input files into the PCM so we don't need to include module map files when
                # building remotely.
                # https://github.com/apple/llvm-project/commit/fb1e7f7d1aca7bcfc341e9214bda8b554f5ae9b6
                swift_toolchain_config.add_arg(
                    "-Xcc",
                    "-Xclang",
                ),
                swift_toolchain_config.add_arg(
                    "-Xcc",
                    "-fmodules-embed-all-files",
                ),
                # Set the base directory of the pcm file to the working directory, which ensures
                # all paths serialized in the PCM are relative.
                # https://github.com/llvm/llvm-project/commit/646e502de0d854cb3ecaca90ab52bebfe59a40cd
                swift_toolchain_config.add_arg(
                    "-Xcc",
                    "-Xclang",
                ),
                swift_toolchain_config.add_arg(
                    "-Xcc",
                    "-fmodule-file-home-is-cwd",
                ),
            ],
            features = [SWIFT_FEATURE_SYSTEM_MODULE],
        ),
    ]

    return SwiftToolchainInfo(
        action_configs = action_configs,
        cc_toolchain_info = base_wift_toolchain.cc_toolchain_info,
        clang_implicit_deps_providers = base_wift_toolchain.clang_implicit_deps_providers,
        developer_dirs = base_wift_toolchain.developer_dirs,
        entry_point_linkopts_provider = base_wift_toolchain.entry_point_linkopts_provider,
        feature_allowlists = base_wift_toolchain.feature_allowlists,
        generated_header_module_implicit_deps_providers = base_wift_toolchain.generated_header_module_implicit_deps_providers,
        implicit_deps_providers = base_wift_toolchain.implicit_deps_providers,
        package_configurations = base_wift_toolchain.package_configurations,
        requested_features = base_wift_toolchain.requested_features,
        swift_worker = base_wift_toolchain.swift_worker,
        test_configuration = base_wift_toolchain.test_configuration,
        tool_configs = base_wift_toolchain.tool_configs,
        unsupported_features = base_wift_toolchain.unsupported_features,
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

    swift_toolchain = _config_swift_toolchain(ctx)
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
