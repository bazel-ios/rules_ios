# This file marks the root of the Bazel workspace.
# See MODULE.bazel for dependencies and setup.
# It is only used when bzlmod is disabled.
# When bzlmod is enabled WORKSPACE.bzlmod is used.

workspace(name = "build_bazel_rules_ios")

load(
    "//rules:repositories.bzl",
    "rules_ios_dependencies",
    "rules_ios_dev_dependencies",
)

rules_ios_dependencies()

rules_ios_dev_dependencies()

load(
    "@build_bazel_rules_apple//apple:repositories.bzl",
    "apple_rules_dependencies",
)

apple_rules_dependencies()

load(
    "@build_bazel_rules_swift//swift:repositories.bzl",
    "swift_rules_dependencies",
)

swift_rules_dependencies()

load(
    "@build_bazel_rules_swift//swift:extras.bzl",
    "swift_rules_extra_dependencies",
)

swift_rules_extra_dependencies()

load(
    "@build_bazel_apple_support//lib:repositories.bzl",
    "apple_support_dependencies",
)

apple_support_dependencies()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load(
    "@bazel_tools//tools/build_defs/repo:git.bzl",
    "git_repository",
)

git_repository(
    name = "io_bazel_stardoc",
    commit = "6f274e903009158504a9d9130d7f7d5f3e9421ed",
    remote = "https://github.com/bazelbuild/stardoc.git",
    shallow_since = "1667581897 -0400",
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

# Download prebuilt binaries buildifier
load("@buildifier_prebuilt//:deps.bzl", "buildifier_prebuilt_deps")

buildifier_prebuilt_deps()

load("@buildifier_prebuilt//:defs.bzl", "buildifier_prebuilt_register_toolchains")

buildifier_prebuilt_register_toolchains()

load(
    "//tests/ios/frameworks/external-dependency:external_dependency.bzl",
    "load_external_test_dependency",
)

load_external_test_dependency()

load(
    "//tests/ios/unit-test/test-imports-app:external_dependency.bzl",
    "load_framework_dependencies",
)

load_framework_dependencies()

load("//tools/toolchains/xcode_configure:xcode_configure.bzl", "xcode_configure")

xcode_configure(
    remote_xcode_label = "",
    xcode_locator_label = "//tools/toolchains/xcode_configure:xcode_locator.m",
)

# This is necessary for cutting tarballs - e.g. for a release
load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")

rules_pkg_dependencies()
