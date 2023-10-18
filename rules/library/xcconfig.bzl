load("//data:xcspecs.bzl", "SETTINGS")
load("//data:xcspec_evals.bzl", "XCSPEC_EVALS")
load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@bazel_skylib//lib:types.bzl", "types")
load("@bazel_skylib//lib:shell.bzl", "shell")

_CLANG = "com.apple.compilers.llvm.clang.1_0"
_SWIFT = "com.apple.xcode.tools.swift.compiler"
_LD = "com.apple.pbx.linkers.ld"
_MOMC = "com.apple.compilers.model.coredata"
_MAPC = "com.apple.compilers.model.coredatamapping"
_IBTOOL = "com.apple.xcode.tools.ibtool.compiler"
_OTHERWISE = "<<otherwise>>"

def _unknown_enum_value(name, option, value, fatal = False):
    if option["Type"] != "Enumeration":
        return

    printer = fail if fatal else print

    printer("{name}: {value} not a valid value, must be one of {options}".format(
        name = name,
        value = repr(value),
        options = repr(option["Values"]),
    ))

def _id(value):
    return value

def _linkopt_xlinker_substitution(args):
    ret = []
    xlinker = None

    for arg in args:
        if xlinker == True:
            xlinker = arg
        elif xlinker:
            if arg != "-Xlinker":
                ret.append("-Wl,{},{}".format(xlinker, arg))
                xlinker = None
        elif arg == "-Xlinker":
            xlinker = True
        else:
            ret.append(arg)

    if xlinker:
        ret.append("-Wl,{}".format(xlinker))

    return ret

def _add_copts_from_option(xcspec, name, option, value, value_escaper, xcconfigs, copts, linkopts):
    _type = option["Type"]
    used_user_config = True

    if value == None:
        if "DefaultValue" in option:
            default_value_function = XCSPEC_EVALS[option["DefaultValue"]]
            if not default_value_function:
                fail("{name}: option specifies a default value ({default}), but the default value function isn't available to evaluate against".format(
                    name = name,
                    default = repr(option["DefaultValue"]),
                ))
            (used_user_config, value) = default_value_function(xcconfigs, SETTINGS[xcspec]["Options"])

    if "Condition" in option:
        condition_function = XCSPEC_EVALS[option["Condition"]]
        if not condition_function:
            fail("{name}: option specifies a condition ({cond}), but the condition function isn't available to evaluate against".format(
                name = name,
                cond = repr(option["Condition"]),
            ))

        (condition_used_user_config, condition) = condition_function(xcconfigs, SETTINGS[xcspec]["Options"])

        if not condition:
            return

        used_user_config = used_user_config or condition_used_user_config

    if not used_user_config:
        # the point of this is to not pollute copts with all of xcode's defaults.
        # only take into account settings that the user's explicit config have influenced
        # (e.g. their config was used in the conditional or default value, if not the value for the setting itself)
        return

    if _type == "Boolean":
        if value not in ("YES", "NO"):
            if value in ("0", ""):
                value = "NO"
            else:
                coerced = "YES"
                printer = print if types.is_string(value) else fail
                printer('{name}: {value} not a valid value, must be "YES" or "NO", inferred as {coerced}'.format(
                    name = name,
                    value = value,
                    coerced = coerced,
                ))
                value = coerced
    elif _type == "Enumeration":
        if value not in option["Values"]:
            _unknown_enum_value(name, option, value)
    elif _type in ("StringList", "PathList") and not types.is_list(value):
        if value == "":
            value = []
        else:
            fail("{name}: {value} not a valid value, must be a list".format(
                name = name,
                value = repr(value),
            ))
    elif _type in ("String", "Path") and not types.is_string(value):
        fail("{name}: {value} not a valid value, must be a string".format(
            name = name,
            value = value,
        ))

    new_linkopts = []

    if "AdditionalLinkerArgs" in option:
        args = option["AdditionalLinkerArgs"]
        if value in args:
            new_linkopts = args[value]
        elif _OTHERWISE in args:
            new_linkopts = args[_OTHERWISE]
        else:
            _unknown_enum_value(name, option, value, fatal = True)

    linkopts.extend([
        arg.replace("$(value)", v)
        for v in (value if types.is_list(value) else [value])
        for arg in _linkopt_xlinker_substitution(new_linkopts)
    ])

    new = None

    if "CommandLineArgs" in option:
        command_line_args = option["CommandLineArgs"]
        if value in command_line_args:
            new = command_line_args[value]
        elif _OTHERWISE in command_line_args:
            new = command_line_args[_OTHERWISE]
        elif not types.is_dict(command_line_args):
            new = command_line_args
        else:
            _unknown_enum_value(name, option, value, fatal = True)
            fail("{name}: {value} was not able to resolve as a command line arg for {arg}".format(
                name = name,
                value = repr(value),
                arg = repr(command_line_args),
            ))
        if not types.is_list(new):
            new = [new]

    elif "CommandLineFlag" in option:
        command_line_flag = option["CommandLineFlag"]
        if _type == "Boolean":
            if value == "YES":
                new = [command_line_flag]
            else:
                new = None
        else:
            new = [command_line_flag, "$(value)"]

    elif "CommandLinePrefixFlag" in option:
        command_line_prefix_flag = option["CommandLinePrefixFlag"]
        new = [command_line_prefix_flag + "$(value)"]

    if new == None:
        return

    if xcspec == _LD:
        new = _linkopt_xlinker_substitution(new)

    copts.extend([
        arg.replace("$(value)", value_escaper(v))
        for v in (value if types.is_list(value) else [value])
        for arg in new
    ])

def copts_from_xcconfig(xcconfig):
    objc_copts = []
    cc_copts = []
    swift_copts = []
    momc_copts = []
    mapc_copts = []
    ibtool_copts = []
    linkopts = []

    xcconfig = dicts.add(
        {
            "CLANG_ENABLE_MODULE_DEBUGGING": "NO",
            "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES": "YES",
        },
        xcconfig,
    )

    ignored_settings = (
        "ALL_OTHER_LDFLAGS",  # should be passed via linkopts
        "CLANG_MODULES_PRUNE_AFTER",  # we don't want to prune the ephemeral module cache
        "CLANG_MODULES_PRUNE_INTERVAL",  # we don't want to prune the ephemeral module cache
        "IBC_MODULE",  # derived by rules_apple
        "GCC_OPTIMIZATION_LEVEL",  # handled by objc_library via compilation_mode
        "LD_LTO_OBJECT_FILE",  # handled by objc_library
        "MAPC_MODULE",  # derived by rules_apple
        "MOMC_MODULE",  # derived by rules_apple
        "SWIFT_MODULE_NAME",  # has its own attr for swift_library
        "CLANG_BITCODE_GENERATION_MODE",  # handled by `--apple_bitcode` flag on Bazel side
        "SWIFT_BITCODE_GENERATION_MODE",  # handled by `--apple_bitcode` flag on Bazel side
        "LD_BITCODE_GENERATION_MODE",  # handled by `--apple_bitcode` flag on Bazel side

        # Bazel platform / target specific attributes - handled by toolchains
        "SWIFT_TARGET_TRIPLE_VARIANTS",
        "SWIFT_TARGET_TRIPLE",
        "SWIFT_DEPLOYMENT_TARGET",
        "LD_TARGET_TRIPLE_VARIANT",
        "LD_TARGET_TRIPLE_ARCHS",
        "CLANG_TARGET_TRIPLE_ARCHS",
        "CLANG_TARGET_TRIPLE_VARIANTS",
        "arch",
    )

    identifiers = [
        (_CLANG, objc_copts, shell.quote),
        (_SWIFT, swift_copts, _id),
        (_LD, linkopts, shell.quote),
        (_MOMC, momc_copts, _id),
        (_MAPC, mapc_copts, _id),
        (_IBTOOL, ibtool_copts, _id),
    ]

    for (id, copts, value_escaper) in identifiers:
        settings = SETTINGS[id]["Options"]
        for (setting, option) in settings.items():
            if setting not in xcconfig and "DefaultValue" not in option:
                continue

            if setting in ignored_settings:
                continue

            value = xcconfig.get(setting)
            _add_copts_from_option(id, setting, option, value, value_escaper, xcconfig, copts, linkopts)

    return struct(
        objc_copts = objc_copts,
        cc_copts = cc_copts,
        swift_copts = swift_copts,
        momc_copts = momc_copts,
        mapc_copts = mapc_copts,
        ibtool_copts = ibtool_copts,
        linkopts = linkopts,
    )

def build_setting_name(build_setting):
    """Returns the name of a given bazel build setting from the fully-qualified label

    Fails if 'build_setting' is not in the expected format

    Args:
        build_setting: The fully-qualified label for a bazel build setting, e.g.,
                       '@repo_name//path/to/package:target_name'

    Returns:
        The string 'target_name' in '@repo_name//path/to/package:target_name'
    """
    build_setting_partition = build_setting.partition(":")

    if len(build_setting_partition) == 3:
        return build_setting_partition[2]
    else:
        fail("Invalid build setting name: %s" % build_setting)

def copts_by_build_setting_with_defaults(xcconfig = {}, fetch_default_xcconfig = {}, xcconfig_by_build_setting = {}):
    """Creates a struct containing different configurable copts

    Each returned copts is a 'select()' statement keyed by the bazel build settings in 'xcconfig_by_build_setting' and each
    resolved value is the result of merging 'xcconfig' with the respective build setting xcconfig and applying the
    default values from 'fetch_default_xcconfig' if necessary.

    For the default value to be resolved ('//conditions:default') this macro follows the same logic described above without
    the 'merging' step, so 'xcconfig' plus default values from 'fetch_default_xcconfig' if necessary.

    Args:
        xcconfig: A dictionary of Xcode build settings to be converted to
                  different `copt` attributes.
        fetch_default_xcconfig: A dictionary of default Xcode build settings
                                to be applied for the keys that are not set.
        xcconfig_by_build_setting: A dictionary where the keys are build settings names and
                                   the values are the respective dictionaries of Xcode build settings

    Returns:
        Struct with different copts behind 'select()' statements
    """
    xcconfig_with_defaults = merge_xcconfigs(fetch_default_xcconfig, xcconfig)

    # Default copts to be used in case no bazel build setting gets resolved
    copts_with_defaults = copts_from_xcconfig(xcconfig_with_defaults)

    objc_copts_by_build_setting = {"//conditions:default": copts_with_defaults.objc_copts}
    cc_copts_by_build_setting = {"//conditions:default": copts_with_defaults.cc_copts}
    swift_copts_by_build_setting = {"//conditions:default": copts_with_defaults.swift_copts}
    momc_copts_by_build_setting = {"//conditions:default": copts_with_defaults.momc_copts}
    mapc_copts_by_build_setting = {"//conditions:default": copts_with_defaults.mapc_copts}
    ibtool_copts_by_build_setting = {"//conditions:default": copts_with_defaults.ibtool_copts}
    linkopts_by_build_setting = {"//conditions:default": copts_with_defaults.linkopts}

    for (build_setting, build_setting_xcconfig) in xcconfig_by_build_setting.items():
        # The values for this bazel build setting should override the values in 'xcconfig'
        # Adding default values if necessary
        merged_xcconfig = merge_xcconfigs(xcconfig_with_defaults, build_setting_xcconfig)

        # The copts to be used in case this bazel build setting gets resolved
        copts = copts_from_xcconfig(merged_xcconfig)

        objc_copts_by_build_setting[build_setting] = copts.objc_copts
        cc_copts_by_build_setting[build_setting] = copts.cc_copts
        swift_copts_by_build_setting[build_setting] = copts.swift_copts
        momc_copts_by_build_setting[build_setting] = copts.momc_copts
        mapc_copts_by_build_setting[build_setting] = copts.mapc_copts
        ibtool_copts_by_build_setting[build_setting] = copts.ibtool_copts
        linkopts_by_build_setting[build_setting] = copts.linkopts

    return struct(
        objc_copts = select(objc_copts_by_build_setting),
        cc_copts = select(cc_copts_by_build_setting),
        swift_copts = select(swift_copts_by_build_setting),
        momc_copts = select(momc_copts_by_build_setting),
        mapc_copts = select(mapc_copts_by_build_setting),
        ibtool_copts = select(ibtool_copts_by_build_setting),
        linkopts = select(linkopts_by_build_setting),
    )

def merge_xcconfigs(*xcconfigs):
    """Merges a list of xcconfigs into a single dictionary

    Overrides keys from the first xcconfig with the values from the latest one if they match.

    Args:
        *xcconfigs: A list of dictionaries of Xcode build settings

    Returns:
        A dictionary of Xcode build settings
    """
    merged_xcconfig = {}
    for xcconfig in xcconfigs:
        for (key, value) in dict(xcconfig).items():
            merged_xcconfig[key] = value

    return merged_xcconfig
