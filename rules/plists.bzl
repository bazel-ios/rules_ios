load("@bazel_skylib//lib:types.bzl", "types")
load("//rules:library.bzl", "write_file")
load("//rules/library:xcconfig.bzl", "build_setting_name")

def write_info_plists_if_needed(name, plists):
    """
    Writes info plists for a bundle if needed.

    Given a list of infoplists, will write out any plists that are passed as a
    dict, and will add a default app Info.plist if no non-dict plists are passed.

    Args:
        name: The name of the bundle target these infoplists are for.
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

def info_plists_by_setting(*, name, infoplists_by_build_setting, default_infoplists):
    infoplists_by_build_setting = dict(infoplists_by_build_setting)
    for (build_setting, plists) in infoplists_by_build_setting.items():
        name_suffix = build_setting_name(build_setting)
        infoplists_by_build_setting[build_setting] = write_info_plists_if_needed(name = "%s.%s" % (name, name_suffix), plists = plists)

    default_infoplists = infoplists_by_build_setting.get("//conditions:default", default_infoplists)
    infoplists_by_build_setting["//conditions:default"] = write_info_plists_if_needed(name = name, plists = default_infoplists)

    return select(infoplists_by_build_setting)
