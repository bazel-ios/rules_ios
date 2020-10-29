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
    "@build_bazel_apple_support//lib:repositories.bzl",
    "apple_support_dependencies",
)

apple_support_dependencies()

load(
    "@com_google_protobuf//:protobuf_deps.bzl",
    "protobuf_deps",
)

protobuf_deps()

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
