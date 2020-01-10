workspace(name = "build_bazel_rules_ios")

load(
    "@bazel_tools//tools/build_defs/repo:git.bzl",
    "git_repository",
)
load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
)

# rules_apple, rules_swift and apple_support no longer support releases. If
# you'd like to pin down these dependencies to a specific commit, please add the
# following to the top of your WORKSPACE, using the commit you'd like to pin for
# each of the repositories.
git_repository(
    name = "build_bazel_rules_apple",
    commit = "96212456d3cd7be9760fe28c077673bb85d46500",
    remote = "https://github.com/bazelbuild/rules_apple.git",
    shallow_since = "1576719323 -0800",
)

git_repository(
    name = "build_bazel_rules_swift",
    commit = "d7757c5ee9724df9454edefa3b4455a401a2ae22",
    remote = "https://github.com/bazelbuild/rules_swift.git",
    shallow_since = "1576775454 -0800",
)

git_repository(
    name = "build_bazel_apple_support",
    commit = "9605c3da1c5bcdddc20d1704b52415a6f3a5f422",
    remote = "https://github.com/bazelbuild/apple_support.git",
    shallow_since = "1570831694 -0700",
)

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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

git_repository(
    name = "io_bazel_stardoc",
    commit = "4378e9b6bb2831de7143580594782f538f461180",
    remote = "https://github.com/bazelbuild/stardoc.git",
    shallow_since = "1570829166 -0400",
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()
