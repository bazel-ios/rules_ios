""" Xcode Project Generation Logic """

load("//rules:legacy_xcodeproj.bzl", legacy_xcodeproj = "xcodeproj")

def xcodeproj(name, **kwargs):
    """Macro that declares current default Xcode project generator (see `rules/legacy_xcodeproj.bzl`)

    Args:
      name: Name of the rule to be declared
      **kwargs: Arguments to propagate
    """

    # Ensures testonly is set (see https://github.com/bazel-ios/rules_ios/pull/573)
    testonly = kwargs.pop("testonly", False)

    legacy_xcodeproj(name = name, testonly = testonly, **kwargs)
