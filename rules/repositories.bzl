"""Definitions for handling Bazel repositories used by the Apple rules."""

load(
    "@bazel_tools//tools/build_defs/repo:git.bzl",
    "git_repository",
)
load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
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
        commit = "96212456d3cd7be9760fe28c077673bb85d46500",
        remote = "https://github.com/bazelbuild/rules_apple.git",
        shallow_since = "1576719323 -0800",
    )

    _maybe(
        git_repository,
        name = "build_bazel_rules_swift",
        commit = "d7757c5ee9724df9454edefa3b4455a401a2ae22",
        remote = "https://github.com/bazelbuild/rules_swift.git",
        shallow_since = "1576775454 -0800",
    )

    _maybe(
        git_repository,
        name = "build_bazel_apple_support",
        commit = "9605c3da1c5bcdddc20d1704b52415a6f3a5f422",
        remote = "https://github.com/bazelbuild/apple_support.git",
        shallow_since = "1570831694 -0700",
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
