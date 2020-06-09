"""Definitions for handling Bazel repositories used by the Apple rules."""

load(
    "@bazel_tools//tools/build_defs/repo:git.bzl",
    "git_repository",
)
load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
    "http_file",
)

def _maybe(repo_rule, name, **kwargs):
    """Executes the given repository rule if it hasn't been executed already.

    Args:
      repo_rule: The repository rule to be executed (e.g.,
          `http_archive`.)
      name: The name of the repository to be defined by the rule.
      **kwargs: Additional arguments passed directly to the repository rule.
    """
    if not native.existing_rule(name):
        repo_rule(name = name, **kwargs)

def rules_ios_dependencies():
    """Fetches repositories that are dependencies of the `rules_apple` workspace.
    """
    _maybe(
        git_repository,
        name = "build_bazel_rules_apple",
        commit = "74eca5857a136b9f1e2020886be76b791eb08231",
        shallow_since = "1590530217 -0700",
        remote = "https://github.com/bazelbuild/rules_apple.git",
    )

    _maybe(
        git_repository,
        name = "build_bazel_rules_swift",
        commit = "6408d85da799ec2af053c4e2883dce3ce6d30f08",
        shallow_since = "1589833120 -0700",
        remote = "https://github.com/bazelbuild/rules_swift.git",
    )

    _maybe(
        git_repository,
        name = "build_bazel_apple_support",
        commit = "501b4afb27745c4813a88ffa28acd901408014e4",
        shallow_since = "1577729628 -0800",
        remote = "https://github.com/bazelbuild/apple_support.git",
    )

    _maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
        ],
    )

    _maybe(
        http_archive,
        name = "com_github_lyft_index_import",
        build_file_content = """\
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")

native_binary(
    name = "index_import",
    src = "index-import",
    out = "index-import",
    visibility = ["//visibility:public"],
)
""",
        canonical_id = "index-import-5.1.1.3",
        sha256 = "0946012f1557a72fcbc65bd3f2e9b2a99d5b1e57e6db43a5ad0c969bddd9e072",
        urls = ["https://github.com/lyft/index-import/releases/download/5.1.1.3/index-import.zip"],
    )

    _maybe(
        http_archive,
        name = "com_github_yonaskolb_xcodegen",
        build_file_content = """\
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")

native_binary(
    name = "xcodegen",
    src = "bin/xcodegen",
    out = "xcodegen",
    data = glob(["share/**/*"]),
    visibility = ["//visibility:public"],
)
""",
        canonical_id = "xcodegen-2.15.2",
        sha256 = "0a53aef09e1b93c5307fc1c411c52a034305ccfd87255c01de7f9ff5141e0d86",
        strip_prefix = "xcodegen",
        urls = ["https://github.com/yonaskolb/XcodeGen/releases/download/2.15.1/xcodegen.zip"],
    )

    # Pinned because 0.2.12 is broken on macOS 10.14
    # https://github.com/google/xctestrunner/issues/18
    _maybe(
        http_file,
        name = "xctestrunner",
        executable = 1,
        sha256 = "9e46d5782a9dc7d40bc93c99377c091886c180b8c4ffb9f79a19a58e234cdb09",
        urls = ["https://github.com/google/xctestrunner/releases/download/0.2.10/ios_test_runner.par"],
    )
