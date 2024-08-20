load("@build_bazel_rules_swift//swift/internal:feature_names.bzl", "SWIFT_FEATURE_SYSTEM_MODULE")
load("@build_bazel_rules_swift//swift/internal:providers.bzl", "create_swift_info")
load("@build_bazel_rules_swift//swift/internal:swift_common.bzl", "swift_common")

def _sdk_clang_module_impl(ctx):
    return [
        swift_common.create_swift_interop_info(
            module_map = ctx.attr.module_map,
            module_name = ctx.attr.module_name,
            requested_features = [SWIFT_FEATURE_SYSTEM_MODULE],
        ),
        # We need to return CcInfo and its compilation_context. We may also consider to update swift_clang_module_aspect.
        # See https://github.com/bazelbuild/rules_swift/blob/d68b21471e4e9d922b75e2b0621082b8ce017d11/swift/internal/swift_clang_module_aspect.bzl#L548
        CcInfo(compilation_context = cc_common.create_compilation_context()),
        # Required to add sdk_clang_module targets to the deps of swift_module_alias.
        # TODO(cshi): create the SwiftInfo correctly
        create_swift_info(),
    ]

sdk_clang_module = rule(
    attrs = {
        "deps": attr.label_list(
            doc = "The deps of the SDK clang module",
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
    doc = """\
A rule representing a SDK clang module. It's required for explicit module builds.
""",
    implementation = _sdk_clang_module_impl,
)
