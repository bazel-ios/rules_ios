""" A rule for adding additional information such as test targets and test environments to a generated scheme """

load("@build_bazel_rules_apple//apple:providers.bzl", "AppleBundleInfo")

AdditionalSchemeInfo = provider(
    """
    Information mapping the scheme for a build target with additional information
    such as test targets to add to a test action.
    """,
    fields = {
        "build_target": "The build target/scheme to add the additional scheme info to.",
        "test_action_targets": "A list of test actions to add to the scheme for the scheme_build_target.",
    },
)

def _additional_scheme_info_impl(ctx):
    test_action_targets = [
        struct(
            name = test_target[AppleBundleInfo].bundle_name,
            environment_variables = ctx.attr.test_environment,
        )
        for test_target in ctx.attr.test_action_targets
    ]

    return [
        AdditionalSchemeInfo(
            build_target = ctx.attr.build_target[AppleBundleInfo].bundle_name,
            test_action_targets = test_action_targets,
        ),
    ]

additional_scheme_info = rule(
    implementation = _additional_scheme_info_impl,
    doc = "Pairs a build target with one or more test targets. Returns list of AdditionalSchemeInfo.",
    attrs = {
        "build_target": attr.label(
            mandatory = True,
            doc = "The build target to attach the additional scheme info to.",
            providers = [AppleBundleInfo],
        ),
        "test_action_targets": attr.label_list(
            mandatory = False,
            doc = "A list of test targets that should be appended to the build_target.",
            allow_empty = True,
            providers = [AppleBundleInfo],
        ),
        "test_environment": attr.string_dict(
            mandatory = False,
            allow_empty = True,
            doc = """
Extra environment variables to pass during tests. This will overwrite 
any value provided in scheme_existing_envvar_overrides.
            """,
            default = {},
        ),
    },
)
