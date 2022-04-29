""" Xcode Project Generation Logic """

load("//rules:legacy_xcodeproj.bzl", legacy_xcodeproj = "xcodeproj")
load("@xchammer//:BazelExtensions/xcodeproject.bzl", xchammer_xcodeproj = "xcode_project")
load("@xchammer//:BazelExtensions/xchammerconfig.bzl", "project_config")

def xcodeproj(name, **kwargs):
    """Macro that allows one to declare one of 'legacy_xcodeproj', 'xchammer_xcodeproj' depending on value of 'use_xchammer' flag

    Args:
      name: Name of the rule to be declared
      **kwargs: Arguments to propagate, the XCHammer specific ones are going to be removed before declaring the legacy rule
    """

    # Pop XCHammer specific attributes so these don't get propagated
    use_xchammer = kwargs.pop("use_xchammer", False)
    generate_xcode_schemes = kwargs.pop("generate_xcode_schemes", False)
    xcconfig_overrides = kwargs.pop("xcconfig_overrides", {})

    if use_xchammer:
        xchammer_xcodeproj(
            name = name,
            testonly = kwargs.get("testonly", False),
            bazel = kwargs.get("bazel_path", "/usr/local/bin/bazel"),
            project_config = project_config(
                generate_xcode_schemes = generate_xcode_schemes,
                paths = ["**"],
                xcconfig_overrides = xcconfig_overrides,
            ),
            targets = kwargs.get("deps", []),
        )
    else:
        legacy_xcodeproj(name = name, **kwargs)
