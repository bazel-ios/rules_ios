"""Definitions for handling Bazel repositories used by the Apple rules."""

load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
    "http_file",
)
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("//rules/third_party:xchammer_repositories.bzl", "xchammer_dependencies")
load("//rules/third_party:xcbuildkit_repositories.bzl", xcbuildkit_dependencies = "dependencies")

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

def github_repo(name, project, repo, ref, sha256 = None, **kwargs):
    """Downloads a repository from GitHub as a tarball.

    Args:
        name: The name of the repository.
        project: The project (user or organization) on GitHub that hosts the repository.
        repo: The name of the repository on GitHub.
        ref: The reference to be downloaded. Can be any named ref, e.g. a commit, branch, or tag.
        sha256: The sha256 of the downloaded tarball.
        **kwargs: additional keyword arguments for http_archive.
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
        **kwargs
    )

def rules_ios_dependencies():
    """Fetches repositories that are dependencies of the `rules_apple` workspace.
    """
    _maybe(
        github_repo,
        name = "build_bazel_rules_swift",
        project = "bazelbuild",
        ref = "cb64a41e3a4c93f67abdfcc0d5f18aa04f02f5b0",
        repo = "rules_swift",
        sha256 = "200a35c2c84096f155a5c6092bac2abf1b2149fbeb3eb730a2923997db079a83",
    )

    _maybe(
        github_repo,
        name = "build_bazel_rules_apple",
        ref = "b43c7f60b584d68d7d187c236d4328162ba2e806",
        project = "bazelbuild",
        repo = "rules_apple",
        sha256 = "d3e8549c0c8966ba0e547a02f5601440be25a0b8143bd57ab5834b65b02c22be",
    )

    _maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
        sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
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

    _maybe(
        new_git_repository,
        name = "arm64-to-sim",
        remote = "https://github.com/bogo/arm64-to-sim.git",
        commit = "25599a28689fa42679f23eb0ff031ebe57d3bb9b",
        shallow_since = "1627075944 -0700",
        build_file_content = """
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary")

swift_binary(
    name = "arm64-to-sim",
    srcs = glob(["Sources/arm64-to-sim/*.swift"]),
    visibility = ["//visibility:public"],
)
        """,
    )
    _maybe(
        http_archive,
        name = "rules_pkg",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/rules_pkg/releases/download/0.7.0/rules_pkg-0.7.0.tar.gz",
            "https://github.com/bazelbuild/rules_pkg/releases/download/0.7.0/rules_pkg-0.7.0.tar.gz",
        ],
        sha256 = "8a298e832762eda1830597d64fe7db58178aa84cd5926d76d5b744d6558941c2",
    )

    _maybe(
        http_file,
        name = "tart",
        urls = ["https://github.com/cirruslabs/tart/releases/download/0.14.0/tart"],
        sha256 = "2c61526aa07ade30ab6534b0fdc0a0edeb56ec2084dadee587e53c46e3a8edc3",
    )

    if not native.existing_rule("xchammer"):
        git_repository(
            name = "xchammer",
            remote = "https://github.com/bazel-ios/xchammer.git",
            # XCHammer dev branch: bazel-ios/rules-ios-xchammer
            commit = "fffd8033bed79e61a908ca1a72acff867a5b5825",
            shallow_since = "1670600984 -0500",
        )
    xchammer_dependencies()

    if not native.existing_rule("xcbuildkit"):
        git_repository(
            name = "xcbuildkit",
            commit = "18a2b0e73d2e0cba759d5b4da24e47af106922d7",
            remote = "https://github.com/jerrymarino/xcbuildkit.git",
        )

    xcbuildkit_dependencies()
