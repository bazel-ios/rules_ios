load("@build_bazel_rules_swift//swift/internal:providers.bzl", "SwiftToolchainInfo")

def _impl(ctx):
    base = ctx.attr.toolchain[SwiftToolchainInfo]
    return [
        SwiftToolchainInfo(
            # Note: we'll need to change out the action_configs here.
            action_configs = base.action_configs,
            all_files = base.all_files,
            cc_toolchain_info = base.cc_toolchain_info,
            clang_implicit_deps_providers = base.clang_implicit_deps_providers,
            cpu = base.cpu,
            feature_allowlists = base.feature_allowlists,
            generated_header_module_implicit_deps_providers = base.generated_header_module_implicit_deps_providers,
            implicit_deps_providers = base.implicit_deps_providers,
            linker_opts_producer = base.linker_opts_producer,
            linker_supports_filelist = base.linker_supports_filelist,
            object_format = base.object_format,
            requested_features = base.requested_features,
            supports_objc_interop = base.supports_objc_interop,
            # Note: we'll need to change out the worker with ours here.
            swift_worker = base.swift_worker,
            system_name = base.system_name,
            test_configuration = base.test_configuration,
            tool_configs = base.tool_configs,
            unsupported_features = base.unsupported_features,
        ),
    ]

# This wraps the rules_swift toolchain: so we get either an Xcode or Linux base
swift_toolchain = rule(
    implementation = _impl,
    attrs = {
       "toolchain": attr.label(
           cfg = "host",
           allow_files = True,
                default = Label(
                    "@build_bazel_rules_swift_local_config//:toolchain",
           ),
       )
    },
)

