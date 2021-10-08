load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

_TestFiles = provider(
    fields = {
        "files": "A glob of files collected for later assertions",
    },
)

def _identical_outputs_test_impl(ctx):
    env = analysistest.begin(ctx)
    all_files = []
    asserts.true(env, len(ctx.attr.deps) > 1)

    for dep in ctx.attr.deps:
        if not _TestFiles in dep:
            continue

        # The input root is the part of the file usually rooted in bazel-out.
        # For starlark transitions output dirs are fingerprinted by the hash of the
        # relevant configuration keys.
        # src/main/java/com/google/devtools/build/lib/analysis/starlark/FunctionTransitionUtil.java
        for input in dep[_TestFiles].files.to_list():
            all_files.append(input.root.path)

    # Expect that we have received multiple swiftmodules
    asserts.true(env, len(all_files) > 1)

    # Assert all swiftmodules have identical outputs ( and most importantly an
    # identical output directory )
    asserts.equals(env, 1, len(depset(all_files).to_list()))
    return analysistest.end(env)

def _collect_transitive_outputs_impl(target, ctx):
    # Collect trans swift_library outputs
    out = []
    if ctx.rule.kind == "swift_library":
        out.extend(target[DefaultInfo].files.to_list())

    if _TestFiles in target:
        out.extend(target[_TestFiles].files.to_list())
    if hasattr(ctx.rule.attr, "srcs"):
        for d in ctx.rule.attr.srcs:
            if _TestFiles in d:
                out.extend(d[_TestFiles].files.to_list())
    if hasattr(ctx.rule.attr, "deps"):
        for d in ctx.rule.attr.deps:
            if _TestFiles in d:
                out.extend(d[_TestFiles].files.to_list())
    return _TestFiles(files = depset(out))

_collect_transitive_outputs = aspect(
    implementation = _collect_transitive_outputs_impl,
    attr_aspects = ["deps", "srcs"],
)

# This test asserts that transitive dependencies have identical outputs for
# different transition paths. In particular, a rules_apple ios_application and
# an a apple_framework that share a swift_library,
# //tests/ios/app:SwiftLib_swift. This test ensures that the actions in both
# builds have functionally equal transitions applied by normalizing their output
# directories into a set.
#
# For instance these tests will fail if there is any delta and requires both:
# - adding apple_common.multi_arch_split to apple_framework.deps - #188
# - the transition yields the same result when used w/rules_apple - #196

# Note:
# The gist of Bazel's configuration resolver is that it will apply
# relevant transitions to keys that are used by a given action. e.g. ios_multi_cpus.
# src/main/java/com/google/devtools/build/lib/analysis/config/ConfigurationResolver.java
#
# In order to get the same configuration for a rule, a given transition has
# to produce the same values for dependent keys for all possible combinations
identical_outputs_test = analysistest.make(
    _identical_outputs_test_impl,
    expect_failure = False,
    attrs = {
        "deps": attr.label_list(
            aspects = [_collect_transitive_outputs],
        ),
    },
)
