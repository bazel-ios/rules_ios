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
        ref = "1b784889f241c5b1bb7d6dc8ee8bde9fbd33245a",
        project = "bazelbuild",
        repo = "rules_apple",
        sha256 = "3660e5076cbdcab5d14530c1bd1de7c94d1d20259c52f2fc107293e32a32847f",
    )

    _maybe(
        github_repo,
        name = "build_bazel_rules_swift",
        ref = "beb3a30faf3982b870924cfcedf01dc596400599",
        project = "bazelbuild",
        repo = "rules_swift",
        sha256 = "0035214dbb2075b5a8f7b2b82351f45a2b0405354d29e22723b0ecc7f9c1ac18",
    )

    _maybe(
        github_repo,
        name = "build_bazel_apple_support",
        ref = "b8755bd2884d6bf651827c30e00bd0ea318e41a2",
        project = "bazelbuild",
        repo = "apple_support",
        sha256 = "07d6a7552a85ef0299ccea18951a527e57ea928159c20f3b9d0b138561313adb",
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
        canonical_id = "index-import-5.2.1.4",
        urls = ["https://github.com/lyft/index-import/releases/download/5.2.1.4/index-import.zip"],
        sha256 = "62f42816baf3b690682b5d6fe543a3c5a4a6ea7499ce1f4e8326c7bd2175989a",
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
        canonical_id = "xcodegen-2.17.0",
        sha256 = "6d1e4a8617e7d13910366c25d1e3ab475158e91e3071cb17f44e3ea29c9a1a41",
        strip_prefix = "xcodegen",
        urls = ["https://github.com/yonaskolb/XcodeGen/releases/download/2.17.0/xcodegen.zip"],
    )
