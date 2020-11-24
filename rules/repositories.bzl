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
        ref = "37a2e525fa048cb9b7bf2ce776804f622c5a4262",
        project = "bazelbuild",
        repo = "rules_apple",
        sha256 = "a7245fc42c288655be3941f31752246966d10024e6abf2ef9ef055feac77ddf0",
    )

    _maybe(
        github_repo,
        name = "build_bazel_rules_swift",
        ref = "ed81c15f9b577880c13b987101100cbac03f45c2",
        project = "bazelbuild",
        repo = "rules_swift",
        sha256 = "9527ef2617be16115ed514d442b6d53d8d824054fd97e5b3ab689fb9d978b8ed",
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
        canonical_id = "xcodegen-2.17.0-19-g775e14c",
        sha256 = "5dbda77da860e615e32f80de8c662757e7ccb7e5012c7fa233b137a4baa36c3d",
        strip_prefix = "xcodegen",
        urls = ["https://github.com/segiddins/XcodeGen/releases/download/2.17.0-19-g775e14c/xcodegen.zip"],
    )
