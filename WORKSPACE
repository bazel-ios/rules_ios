workspace(name = "build_bazel_rules_ios")

load(
    "//rules:repositories.bzl",
    "rules_ios_bazel4_arm64_sim_dependencies",
    "rules_ios_dependencies",
)

rules_ios_bazel4_arm64_sim_dependencies()

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
    commit = "fa1878a1c4eae78a8aff016500777bedbc0bdf32",
    remote = "https://github.com/segiddins/stardoc.git",
    shallow_since = "1599264569 -0700",
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
    name = "buildifier.mac",
    executable = True,
    sha256 = "7ecd2dac543dd2371a2261bda3eb5cbe72f54596b73f372671368f0ed5c77646",
    # This release should correpsond with the .bazelrc. e.g. use 4.0 when the
    # .bazelversion uses 4.0
    urls = ["https://github.com/bazelbuild/buildtools/releases/download/3.5.0/buildifier.mac"],
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
