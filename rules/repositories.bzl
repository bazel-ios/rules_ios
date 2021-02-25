"""Definitions for handling Bazel repositories used by the Apple rules."""

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

def github_repo(name, project, repo, ref, sha256 = None):
    """Downloads a repository from GitHub as a tarball.

    Args:
        name: The name of the repository.
        project: The project (user or organization) on GitHub that hosts the repository.
        repo: The name of the repository on GitHub.
        ref: The reference to be downloaded. Can be any named ref, e.g. a commit, branch, or tag.
        sha256: The sha256 of the downloaded tarball.
    """

    github_url = "https://github.com/{project}/{repo}/archive/{ref}.zip".format(
        project = project,
        repo = repo,
        ref = ref,
    )
    http_archive(
        name = name,
        strip_prefix = "%s-%s" % (repo, ref.replace("/", "-")),
        url = github_url,
        sha256 = sha256,
        canonical_id = github_url,
    )

def rules_ios_dependencies():
    """Fetches repositories that are dependencies of the `rules_apple` workspace.
    """
    _maybe(
        github_repo,
        name = "build_bazel_rules_apple",
        ref = "572aee29236aa6aa850484d5706b79aa2a098219",
        project = "bazelbuild",
        repo = "rules_apple",
        sha256 = "1fff3fa1e565111a8f678b4698792101844f57b2e78c5e374431d0ebe97f6b6c",
    )

    # Note: this is a branch of the rules_swift PR
    # https://github.com/bazelbuild/rules_swift/pull/567
    _maybe(
        github_repo,
        name = "build_bazel_rules_swift",
        ref = "d8fff1f3ef0b057085c875421c15cfd83fcbee28",
        project = "bazel-ios",
        repo = "rules_swift",
        sha256 = "c8768b871e9726efe0245b3b3a60b18f6a41f9735d864bfe97f17bf7d0ae47e9",
    )

    _maybe(
        github_repo,
        name = "build_bazel_apple_support",
        ref = "2583fa0bfd6909e7936da5b30e3547ba13e198dc",
        project = "bazelbuild",
        repo = "apple_support",
        sha256 = "9bec12891ac89db763f625c5f26975e104ace492f19ea37b664e1520897be761",
    )

    _maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz",
        ],
        sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
    )

    # Note: it relies on `index-import` to import indexes. Longer term this
    # dependency may be added by rules_swift
    _maybe(
        http_archive,
        name = "build_bazel_rules_swift_index_import",
        build_file_content = """\
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")

native_binary(
    name = "index_import",
    src = "index-import",
    out = "index-import",
    visibility = ["//visibility:public"],
)

native_binary(
    name = "validate_index",
    src = "validate-index",
    out = "validate-index",
    visibility = ["//visibility:public"],
)

native_binary(
    name = "absolute_unit",
    src = "absolute-unit",
    out = "absolute-unit",
    visibility = ["//visibility:public"],
)
""",
        canonical_id = "index-import-5.3.2.5",
        urls = ["https://github.com/bazel-ios/index-import/releases/download/5.3.2.5/index-import.zip"],
        sha256 = "79e9b2cd3e988155b86668c56d95705e1a4a7c7b6d702ff5ded3a18d1291a39a",
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
        canonical_id = "xcodegen-2.18.0-12-g04d6749",
        sha256 = "3742eee89850cea75367b0f67662a58da5765f66c1be9b4189a59529b4e5099e",
        strip_prefix = "xcodegen",
        urls = ["https://github.com/segiddins/XcodeGen/releases/download/2.18.0-12-g04d6749/xcodegen.zip"],
    )
