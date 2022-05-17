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
        ref = "22192877498705ff1adbecd820fdc2724414b0b2",
        repo = "rules_swift",
        sha256 = "e091dc5b0c727873cec5ffa9622b563e9301d8136f4eed72ebb0ef575956cd3c",
    )

    _maybe(
        github_repo,
        name = "build_bazel_rules_apple",
        ref = "7115f0188d141d57d64a6875735847c975956dae",  # tag 0.34
        project = "bazelbuild",
        repo = "rules_apple",
        sha256 = "ddb53fb63947d068f4f1cc492c144c459e474a05d9db157ccf9457485aad2562",
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
        shallow_since = "1636567136 -0500",
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
            commit = "8dce2aab58ce5e8d607237b8aa1080352c19366a",
            shallow_since = "1652721030 -0700",
        )
    xchammer_dependencies()

    if not native.existing_rule("xcbuildkit"):
        git_repository(
            name = "xcbuildkit",
            commit = "b619d25f65cf7195c57e2dbc26d488e5606e763a",
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
