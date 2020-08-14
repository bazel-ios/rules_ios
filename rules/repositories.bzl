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
        ref = "eadfa72e26dd8b459038dc83fc440759daff65c6",
        project = "bazelbuild",
        repo = "rules_apple",
        #sha256 = "3100977922a83c71742ab38cd433e8878e3692d8106a8107126c59e3ca6e50f3",
    )

    _maybe(
        github_repo,
        name = "build_bazel_rules_swift",
        ref = "15d2b18ac7a71796984c4064fc0b570260969ac3",
        project = "bazelbuild",
        repo = "rules_swift",
        sha256 = "566bfce66201c9264bfc4bc5a84260c8039858158432eda012ec9907feceff41",
    )

    _maybe(
        github_repo,
        name = "build_bazel_apple_support",
        ref = "501b4afb27745c4813a88ffa28acd901408014e4",
        project = "bazelbuild",
        repo = "apple_support",
        sha256 = "8aa07a6388e121763c0164624feac9b20841afa2dd87bac0ba0c3ed1d56feb70",
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
        canonical_id = "xcodegen-2.16.0",
        sha256 = "6c2e212e2dd8000e5cb35aadc772d58d411924d8484f9946f6653aa50e613d31",
        strip_prefix = "xcodegen",
        urls = ["https://github.com/yonaskolb/XcodeGen/releases/download/2.16.0/xcodegen.zip"],
    )
