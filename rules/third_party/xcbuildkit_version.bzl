"""
Copied from: https://github.com/jerrymarino/xcbuildkit/blob/master/BazelExtensions/version.bzl
"""

def _info_impl(ctx):
    ctx.file("BUILD", content = "exports_files([\"ref\"])")
    ctx.file("WORKSPACE", content = "")
    if ctx.attr.value:
        ctx.file("ref", content = str(ctx.attr.value))
    else:
        ctx.file("ref", content = "")

_repo_info = repository_rule(
    implementation = _info_impl,
    attrs = {"value": attr.string()},
    local = True,
)

# While defining a repository, pass info about the repo
# e.g. native.existing_rule("some")["commit"]
# The git rule currently deletes the repo
# https://github.com/bazelbuild/bazel/blob/master/tools/build_defs/repo/git.bzl#L179
def _get_ref(rule):
    if not rule:
        return None
    if rule["kind"] != "git_repository":
        return None
    if rule["commit"]:
        return rule["commit"]
    if rule["tag"]:
        return rule["tag"]
    print("WARNING: using unstable build tag")
    if rule["branch"]:
        return rule["branch"]

def repo_info(name):
    external_rule = native.existing_rule(name)
    _repo_info(name = name + "_repo_info", value = _get_ref(external_rule))
