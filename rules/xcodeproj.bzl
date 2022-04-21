""" Xcode Project Generation Logic """

load("//rules:legacy_xcodeproj.bzl", legacy_xcodeproj = "xcodeproj")
load("@xchammer//:BazelExtensions/xcodeproject.bzl", xchammer_xcodeproj = "xcode_project")
load("@xchammer//:BazelExtensions/xchammerconfig.bzl", "project_config")

def xcodeproj(name, **kwargs):
    if kwargs.pop("use_xchammer", False):
        xchammer_xcodeproj(
            name = name,
            bazel = kwargs.get("bazel_path", "/usr/local/bin/bazel"),
            project_config = project_config(
                generate_xcode_schemes = kwargs.pop("generate_xcode_schemes", False),
                paths = ["**"],
            ),
            targets = kwargs.get("deps", []),
        )
    else:
        legacy_xcodeproj(name = name, **kwargs)
