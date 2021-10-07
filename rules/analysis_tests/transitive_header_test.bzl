load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo", "swift_common")

def _transitive_header_test_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.true(env, len(ctx.attr.deps) > 0)
    target_under_test = analysistest.target_under_test(env)
    target_headers = target_under_test[CcInfo].compilation_context.headers.to_list()
    for dep in ctx.attr.deps:
        asserts.true(env, CcInfo in dep)
        dep_headers = dep[CcInfo].compilation_context.headers.to_list()
        for dep_header in dep_headers:
            # Assert that all of the dep headers are in the target
            has_header = dep_header in target_headers
            asserts.true(env, has_header)
    return analysistest.end(env)

# The headers test allows a user to assert that tests are propagated to actions
# from arbitrary deps. Given a target_under_test, supply transitive deps or
# virutally any file group.
transitive_header_test = analysistest.make(
    _transitive_header_test_impl,
    expect_failure = False,
    attrs = {
        "deps": attr.label_list(allow_empty = False),
    },
)
