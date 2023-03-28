""" Xcode Project Generation Logic """

load("//rules:legacy_xcodeproj.bzl", legacy_xcodeproj = "xcodeproj")
load("@xchammer//:BazelExtensions/xcodeproject.bzl", xchammer_xcodeproj = "xcode_project")
load("@xchammer//:BazelExtensions/xchammerconfig.bzl", "project_config")
load("//rules/third_party:xchammer_helpers.bzl", "patch_bazel_build_service_config")
load("@rules_xcodeproj//xcodeproj:defs.bzl", rules_xcodeproj = "xcodeproj")

_GENERATORS = [
    "legacy",
    "xchammer",
    "rules_xcodeproj",
]

def xcodeproj(
        name,
        generator = "legacy",
        **kwargs):
    """Macro that allows one to use different Xcode generators via the `generator` attribute.

    - Accepted values defined in `_GENERATORS = ["legacy", "xchammer", "rules_xcodeproj"]`
    - kwargs are propagated to the respective generator

    Note: XCHammer is not receiving all kwargs due to the initial intent being to handle that for rules_ios users,
    this should probably change and instead we should just propagate the kwargs like we're doing for the other ones

    Args:
      name: A unique name for this target
      generator: One of ["legacy", "xchammer", "rules_xcodeproj"], defaults to "legacy"
      **kwargs: Arguments to propagate to the respective generator
    """
    generator = kwargs.pop("generator", "legacy")
    if generator not in _GENERATORS:
        fail("[ERROR] Unsupported generator: {}. Acceptable values: {}".format(generator, _GENERATORS))

    # Making sure this attribute is set to address rules_swift requirement
    # See: https://github.com/bazel-ios/rules_ios/pull/573
    testonly = kwargs.pop("testonly", False)

    if generator == "legacy":
        legacy_xcodeproj(
            name = name,
            testonly = testonly,
            **kwargs
        )
    elif generator == "rules_xcodeproj":
        rules_xcodeproj(
            name = name,
            testonly = testonly,
            **kwargs
        )
    elif generator == "xchammer":
        xchammer_xcodeproj(
            name = name,
            testonly = testonly,
            bazel = kwargs.get("bazel_path", "/usr/local/bin/bazel"),
            project_config = project_config(
                generate_xcode_schemes = kwargs.pop("generate_xcode_schemes", False),
                paths = ["**"],
                xcconfig_overrides = kwargs.pop("xcconfig_overrides", {}),
            ),
            bazel_build_service_config = patch_bazel_build_service_config(name, kwargs.pop("bazel_build_service_config", None)),
            targets = kwargs.pop("deps", []),
        )
