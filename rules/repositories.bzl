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

def _get_bazel_version():
    bazel_version = getattr(native, "bazel_version", "")
    if bazel_version:
        parts = bazel_version.split(".")
        if len(parts) > 2:
            return struct(major = parts[0], minor = parts[1], patch = parts[2])

    # Unknown, but don't crash
    return struct(major = 0, minor = 0, patch = 0)

def rules_ios_dependencies(
        load_xchammer_dependencies = False):
    """Fetches repositories that are dependencies of `rules_ios`.

    Args:
        load_xchammer_dependencies: if `True` loads XCHammer and xcbuildkit dependencies (this is considered "alpha" software at the moment, see `README`)
    """
    _maybe(
        github_repo,
        name = "build_bazel_rules_swift",
        project = "bazelbuild",
        ref = "17e20f7edf27e647f1b45f11ed75d51c17820c3b",
        repo = "rules_swift",
        sha256 = "d50c2cb6f1c2c30cf44a8ea60469cd399f7458061169bde76a177b63d6b74330",
    )

    bazel_version = _get_bazel_version()
    if bazel_version.major == "5":
        # LTS support. Some of our third party deps from bazelbuild org don't
        # support LTS but from time to time we'll evaluate supporting this to
        # allow us to all run on HEAD
        # For rules_apple, we maintain a tag rules_ios_1.0
        _maybe(
            github_repo,
            name = "build_bazel_rules_apple",
            ref = "6f93e73382a01595d576247db9fa886769536605",
            project = "bazelbuild",
            repo = "rules_apple",
            sha256 = "1618fc82e556ebc97ea360b8cacd3365ca3b0e0a85ccb32422468204843e752d",
        )
    else:
        _maybe(
            github_repo,
            name = "build_bazel_rules_apple",
            ref = "915ac30a9fa1fd3809599a5ab90fa1c6640fe8dc",
            project = "bazelbuild",
            repo = "rules_apple",
            sha256 = "0204016496a39d5c70247650e098905d129f25347c7e1f019f838ca74252ce2d",
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

    if load_xchammer_dependencies:
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
