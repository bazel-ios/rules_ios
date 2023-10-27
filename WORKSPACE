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

# Storing in a variable so `.github/workflows/tests.yml` can easily
# mutate this before running `rules_ios`s CI tests
LOAD_RULES_APPLE_2_DEPS = False

rules_ios_dependencies(load_rules_apple_2_dependencies = LOAD_RULES_APPLE_2_DEPS)

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

# Load stardoc and it's deps

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

load("@rules_jvm_external//:repositories.bzl", "rules_jvm_external_deps")

rules_jvm_external_deps()

load("@rules_jvm_external//:setup.bzl", "rules_jvm_external_setup")

rules_jvm_external_setup()

load("@io_bazel_stardoc//:deps.bzl", "stardoc_external_deps")

stardoc_external_deps()

load("@stardoc_maven//:defs.bzl", stardoc_pinned_maven_install = "pinned_maven_install")

stardoc_pinned_maven_install()

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
