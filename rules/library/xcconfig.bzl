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
        expected_value_type = types
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

    linkopts += [
        arg.replace("$(value)", v)
        for v in (value if types.is_list(value) else [value])
        for arg in new_linkopts
    ]

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

    copts += [
        arg.replace("$(value)", value_escaper(v))
        for v in (value if types.is_list(value) else [value])
        for arg in new
    ]

def settings_from_xcconfig(xcconfig):
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
        "CLANG_MODULES_PRUNE_INTERVAL",  # we don't want to prune the ephemeral module cache
        "CLANG_MODULES_PRUNE_AFTER",  # we don't want to prune the ephemeral module cache
        "ALL_OTHER_LDFLAGS",  # should be passed via linkopts
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
