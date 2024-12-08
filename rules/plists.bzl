"""
Defines macros for working with plist files.
"""

load("@bazel_skylib//lib:types.bzl", "types")
load("@bazel_skylib//lib:sets.bzl", "sets")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@build_bazel_rules_ios//rules:substitute_build_settings.bzl", "substitute_build_settings")
load("//rules/library:xcconfig.bzl", "build_setting_name", "merge_xcconfigs")

def process_infoplists(name, infoplists, infoplists_by_build_setting, xcconfig, xcconfig_by_build_setting):
    """
    Constructs substituted_plists by substituting build settings from an xcconfig dict into the variables of a plist.

    Args:
        name: The name of the target that the plist is being generated for.
        infoplists: The plist files to be manipulated
        infoplists_by_build_setting: A dictionary of infoplists keyed by config_setting, merged with infoplists created here.
        xcconfig: the default build settings to expand the infoplists with
        xcconfig_by_build_setting: the build settings grouped by config_setting to expand the infoplists with

    Returns:
        A selectable dict of the substituted_plists grouped by config_setting
    """
    infoplists_by_build_setting = dict(infoplists_by_build_setting)
    xcconfig_by_build_setting = dict(xcconfig_by_build_setting)

    # Final substituted infoplists_by_build_setting dict
    substituted_infoplists_by_build_setting = {}

    # Default infoplists are any defined in `infoplists`
    default_infoplists = infoplists if infoplists else []

    # Default xcconfig is the one defined in `xcconfig`
    default_xcconfig = xcconfig if xcconfig else {}

    # Collect a set of config settings to iterate over
    merged_xcconfigs = {}
    for config_setting_name in xcconfig_by_build_setting.keys():
        xccconfig_for_build_setting = xcconfig_by_build_setting.get(config_setting_name, {})
        merged_xcconfigs[config_setting_name]  = merge_xcconfigs(default_xcconfig, xccconfig_for_build_setting)

    # If someone hasn't specified "//conditions:default" - inject it there as upstream callers will `select` on this
    if len(infoplists_by_build_setting.keys()) == 0:
        infoplists_by_build_setting["//conditions:default"] = default_infoplists

    # Substitute the infoplists_by_build_setting
    for config_setting_name in infoplists_by_build_setting.keys():
        name_suffix = build_setting_name(config_setting_name)
        infoplists_for_build_setting = infoplists_by_build_setting.get(config_setting_name, default_infoplists)

        # Substitute the build settings into the plists for this config_setting
        substituted_infoplists_by_build_setting[config_setting_name] = [
            substituted_plist(
                name = "_%s.%s.%s.info" % (name, name_suffix, idx),
                plist = plist,
                xcconfig = select(merged_xcconfigs) if len(merged_xcconfigs.keys()) > 0 else None
            )
            for idx, plist in enumerate(write_info_plists_if_needed(name = "%s.%s" % (name, name_suffix), plists = infoplists_for_build_setting))
        ]

    return substituted_infoplists_by_build_setting

def substituted_plist(name, plist, xcconfig):
    """
    Substitutes build settings from an xcconfig dict into the variables of a plist.

    Args:
      name: The name of the plist.
      plist: The plist file to substitute into.
      xcconfig: The xcconfig variables for substitution.

    Returns:
        The plist target with the substituted variables.
    """
    if not plist:
        return None

    sub_plist = _substitute_plist_vars(name, plist, xcconfig)

    if sub_plist:
        return sub_plist
    else:
        return plist

def write_info_plists_if_needed(name, plists):
    """
    Writes info plists for a bundle if needed.

    Given a list of infoplists, will write out any plists that are passed as a
    dict, and will add a default app Info.plist if no non-dict plists are passed.

    Args:
        name: The name of the bundle target these infoplists are for.
        plists: A list of either labels or dicts.

    Returns:
        A list of labels to the generated Info.plist files.
    """
    already_written_plists = []
    written_plists = []
    for idx, plist in enumerate(plists):
        if types.is_dict(plist):
            plist_name = "{name}.infoplist.{idx}".format(name = name, idx = idx)
            write_file(
                name = plist_name,
                out = plist_name + ".plist",
                content = [json.encode(struct(**plist))],
            )
            written_plists.append(plist_name)
        else:
            already_written_plists.append(plist)

    if not already_written_plists:
        already_written_plists.append("@build_bazel_rules_ios//rules/test_host_app:Info.plist")

    return already_written_plists + written_plists

def _substitute_plist_vars(name, plist, xcconfig):
    """
    Expands build settings in the given plist file with variables from the given xcconfig.

    Args:
        name: the name of the generated plist.
        plist: the plist file to be substituted.
        xcconfig: the build settings to expand against.
    Returns:
        The name of the substituted plist
    """
    substitute_build_settings(
        name = name,
        source = plist,
        variables = xcconfig,
        tags = ["manual"],
    )
    return name
