"""Definitions for handling Bazel repositories used by the Apple rules."""

load(
    "@bazel_tools//tools/build_defs/repo:http.bzl",
    "http_archive",
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
        project = "bazel-ios",
        ref = "8d4b096b90e47095755e47c27e749ae9b9f83e81",
        repo = "rules_swift",
        sha256 = "83eb780db78f6c99cd97d3ff8c0e9bed1a6a3a4cba57476c6e1d2d989c52e17a",
    )

    _maybe(
        github_repo,
        name = "build_bazel_rules_apple",
        ref = "029eab0a6bbb4147d227d623721b205eb62aca9c",
        project = "bazelbuild",
        repo = "rules_apple",
        sha256 = "b12455dbcaa31c4a42194aed59987d6abce6f04b4891389cd8fe5e817ae6b0ee",
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

    if not native.existing_rule("xchammer"):
        git_repository(
            name = "xchammer",
            remote = "https://github.com/bazel-ios/xchammer.git",
            # XCHammer dev branch: bazel-ios/rules-ios-xchammer
            commit = "4caec7bae6f5cb99c5cf29cefd0b345967bdd61b",
            shallow_since = "1656517476 -0500",
        )
    xchammer_dependencies()

    if not native.existing_rule("xcbuildkit"):
        git_repository(
            name = "xcbuildkit",
            commit = "1e1155dc4aa9d7dc4260fb5c287acc0b299bbd76",
            remote = "https://github.com/jerrymarino/xcbuildkit.git",
        )

    xcbuildkit_dependencies()

def _impl(ctx):
    ctx.symlink(str(ctx.path(ctx.attr.rules_ios).dirname) + "/" + ctx.attr.path, "")

sub_repository = repository_rule(
    implementation = _impl,
    local = True,
    attrs = {
        "path": attr.string(mandatory = True),
        "rules_ios": attr.label(default = "@build_bazel_rules_ios//:BUILD.bazel"),
    },
)

def rules_ios_bazel4_arm64_sim_dependencies():
    # Setup all of the repositories for Bazel4 arm64
    # See .bazelrc for an example of the features
    sub_repository(
        name = "local_config_cc",
        path = "tools/toolchains/bazel4_local_config_cc",
    )

    sub_repository(
        name = "local_config_cc_toolchains",
        path = "tools/toolchains/bazel4_local_config_cc_toolchains",
    )
