""" Xcode Project Generation Logic """

load("//rules:legacy_xcodeproj.bzl", legacy_xcodeproj = "xcodeproj")
load("@xchammer//:BazelExtensions/xcodeproject.bzl", xchammer_xcodeproj = "xcode_project")
load("@xchammer//:BazelExtensions/xchammerconfig.bzl", "bazel_build_service_config", "project_config")
load("//rules:library.bzl", "GLOBAL_INDEX_STORE_PATH")

def _patch_bazel_build_service_config(name, kwargs_bazel_build_service_config):
    """Adds sensible defaults

    If users don't specify these values adding defaults that make sense in rules_ios, XCHammer adds
    its own default values if not specified otherwise (very similar to these atm).

    It's really important to align the index stores with `xcbuildkit` so 'GLOBAL_INDEX_STORE_PATH' is always set
    for now since this is how `rules_ios` is setup. Later on we can make this more configurable.
    """
    if kwargs_bazel_build_service_config:
        return bazel_build_service_config(
            bep_path = kwargs_bazel_build_service_config.bepPath if kwargs_bazel_build_service_config.bepPath else "/tmp/{}.bep".format(name),
            index_store_path = "$SRCROOT/%s" % GLOBAL_INDEX_STORE_PATH,
            indexing_data_dir = kwargs_bazel_build_service_config.indexingDataDir if kwargs_bazel_build_service_config.indexingDataDir else "/tmp/xcbuildkit-data/{}/indexing".format(name),
            indexing_enabled = kwargs_bazel_build_service_config.indexingEnabled if kwargs_bazel_build_service_config.indexingEnabled else False,
            progress_bar_enabled = kwargs_bazel_build_service_config.progressBarEnabled if kwargs_bazel_build_service_config.progressBarEnabled else False,
        )
    return None

def xcodeproj(name, **kwargs):
    """Macro that allows one to declare one of 'legacy_xcodeproj', 'xchammer_xcodeproj' depending on value of 'use_xchammer' flag

    Args:
      name: Name of the rule to be declared
      **kwargs: Arguments to propagate, the XCHammer specific ones are going to be removed before declaring the legacy rule
    """

    # Pop XCHammer specific attributes so these don't get propagated to `legacy_xcodeproj`
    use_xchammer = kwargs.pop("use_xchammer", False)
    generate_xcode_schemes = kwargs.pop("generate_xcode_schemes", False)
    xcconfig_overrides = kwargs.pop("xcconfig_overrides", {})
    testonly = kwargs.pop("testonly", False)
    bazel_build_service_config = _patch_bazel_build_service_config(name, kwargs.pop("bazel_build_service_config", None))

    if use_xchammer:
        xchammer_xcodeproj(
            name = name,
            testonly = testonly,
            bazel = kwargs.get("bazel_path", "/usr/local/bin/bazel"),
            project_config = project_config(
                generate_xcode_schemes = generate_xcode_schemes,
                paths = ["**"],
                xcconfig_overrides = xcconfig_overrides,
            ),
            bazel_build_service_config = bazel_build_service_config,
            targets = kwargs.get("deps", []),
        )
    else:
        legacy_xcodeproj(name = name, testonly = testonly, **kwargs)
