workspace(name = "build_bazel_rules_ios")

load(
    "//rules:repositories.bzl",
    "rules_ios_dependencies",
)

rules_ios_dependencies()

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
    commit = "f4d4b3a965c9ae36feeff5eb3171d6ba17406b84",
    remote = "https://github.com/bazelbuild/stardoc.git",
    shallow_since = "1636567136 -0500",
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

load("@build_bazel_rules_ios//repository_rules:framework_builder.bzl", "build_carthage_frameworks", "build_cocoapods_frameworks")

build_carthage_frameworks(
    name = "carthage",
    carthage_version = "0.36.0",
    directory = "tests/ios/frameworks/sources-with-prebuilt-binaries",
)

build_cocoapods_frameworks(
    name = "cocoapods",
    directory = "tests/ios/frameworks/sources-with-prebuilt-binaries",
)

load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_file",
)

# Download offical release of buidifier.mac
http_file(
    name = "buildifier.mac.amd64",
    executable = True,
    sha256 = "2cb0a54683633ef6de4e0491072e22e66ac9c6389051432b76200deeeeaf93fb",
    urls = ["https://github.com/bazelbuild/buildtools/releases/download/5.0.1/buildifier-darwin-amd64"],
)

http_file(
    name = "buildifier.mac.arm64",
    executable = True,
    sha256 = "4da23315f0dccabf878c8227fddbccf35545b23b3cb6225bfcf3107689cc4364",
    urls = ["https://github.com/bazelbuild/buildtools/releases/download/5.0.1/buildifier-darwin-arm64"],
)

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
