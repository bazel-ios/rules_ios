load("@bazel_skylib//lib:types.bzl", "types")
load("@build_bazel_rules_apple//apple:ios.bzl", rules_apple_ios_application = "ios_application")
load("//rules:library.bzl", "apple_library", "write_file")

_IOS_APPLICATION_KWARGS = [
    "bundle_id",
    "env",
    "minimum_os_version",
    "test_host",
    "families",
    "entitlements",
    "visibility",
    "launch_storyboard",
    "app_icons",
]

def write_info_plists_if_needed(name, plists):
    """
    Writes info plists for an app if needed.

    Given a list of infoplists, will write out any plists that are passed as a
    dict, and will add a default app Info.plist if no non-dict plists are passed.

    Args:
        name: The name of the app target these infoplists are for.
        plists: A list of either labels or dicts.
    """
    already_written_plists = []
    written_plists = []
    for idx, plist in enumerate(plists):
        if types.is_dict(plist):
            plist_name = "{name}.infoplist.{idx}".format(name = name, idx = idx)
            write_file(
                name = plist_name,
                destination = plist_name + ".plist",
                content = struct(**plist).to_json(),
            )
            written_plists.append(plist_name)
        else:
            already_written_plists.append(plist)

    if not already_written_plists:
        already_written_plists.append("@build_bazel_rules_ios//rules/test_host_app:Info.plist")

    return already_written_plists + written_plists

def ios_application(name, apple_library = apple_library, **kwargs):
    """
    Builds and packages an iOS application.

    Args:
        name: The name of the iOS application.
        apple_library: The macro used to package sources into a library.
        kwargs: Arguments passed to the apple_library and ios_application rules as appropriate.
    """
    infoplists = write_info_plists_if_needed(name = name, plists = kwargs.pop("infoplists", []))
    application_kwargs = {arg: kwargs.pop(arg) for arg in _IOS_APPLICATION_KWARGS if arg in kwargs}
    library = apple_library(name = name, namespace_is_module_name = False, **kwargs)

    application_kwargs["launch_storyboard"] = application_kwargs.pop("launch_storyboard", library.launch_screen_storyboard_name)
    application_kwargs["families"] = application_kwargs.pop("families", ["iphone", "ipad"])

    rules_apple_ios_application(
        name = name,
        deps = library.deps,
        infoplists = infoplists,
        **application_kwargs
    )
