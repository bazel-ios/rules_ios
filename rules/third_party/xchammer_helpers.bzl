"""
Helper macros to process input for XCHammer and xcbuildkit
"""

load("//rules:library.bzl", "GLOBAL_INDEX_STORE_PATH")
load("@xchammer//:BazelExtensions/xchammerconfig.bzl", "bazel_build_service_config")

def patch_bazel_build_service_config(name, kwargs_bazel_build_service_config):
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
