workspace(name = "build_bazel_rules_ios")

load(
    "@bazel_tools//tools/build_defs/repo:git.bzl",
    "git_repository",
)
load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
)

git_repository(
    name = "build_bazel_rules_swift",
    commit = "e7ce2d13936a1fe234317f228ef7194f27f8520a",
    remote = "https://github.com/bazelbuild/rules_swift.git",
    shallow_since = "1574447681 -0800",
)

git_repository(
    name = "build_bazel_apple_support",
    commit = "9605c3da1c5bcdddc20d1704b52415a6f3a5f422",
    remote = "https://github.com/bazelbuild/apple_support.git",
    shallow_since = "1570831694 -0700",
)

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
