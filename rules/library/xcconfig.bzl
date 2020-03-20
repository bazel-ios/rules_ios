load("//data:xcspecs.bzl", "SETTINGS")
load("@bazel_skylib//lib:types.bzl", "types")

_CLANG = "com.apple.compilers.llvm.clang.1_0"
_SWIFT = "com.apple.xcode.tools.swift.compiler"
_LD = "com.apple.pbx.linkers.ld"
_MOMC = "com.apple.compilers.model.coredata"
_MAPC = "com.apple.compilers.model.coredatamapping"
_IBTOOL = "com.apple.xcode.tools.ibtool.compiler"
_OTHERWISE = "<<otherwise>>"

def _add_copts_from_option(xcspec, option, value, copts, linkopts):
    _type = option["Type"]
    name = option["Name"]

    if _type == "Boolean":
        if value not in ("YES", "NO"):
            coerced = "YES" if value != "0" else "NO"
            print('{name}: {value} not a valid value, must be "YES" or "NO", inferred as {coerced}'.format(
                name = name,
                value = value,
                coerced = coerced,
            ))
            value = coerced
    elif _type == "Enumeration":
        if value not in option["Values"]:
            print("{name}: {value} not a valid value, must be one of {options}".format(
                name = name,
                value = repr(value),
                options = repr(option["Values"]),
            ))
        expected_value_type = types
    elif _type in ("StringList", "PathList") and not types.is_list(value):
        fail("{name}: {value} not a valid value, must be a list".format(
            name = name,
            value = value,
        ))
    elif _type in ("String", "Path") and not types.is_string(value):
        fail("{name}: {value} not a valid value, must be a string".format(
            name = name,
            value = value,
        ))

    if option.get("Condition"):
        fail("{name}: option specifies a condition ({cond}), which is currently unsupported".format(
            name = name,
            cond = repr(option["Condition"]),
        ))

    new_linkopts = []

    if "AdditionalLinkerArgs" in option:
        args = option["AdditionalLinkerArgs"]
        if value in args:
            new_linkopts = args[value]
        elif _OTHERWISE in args:
            new_linkopts = args[_OTHERWISE]

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
            if option["DefaultValue"] == value:
                new = []
            else:
                new = [command_line_flag]
        else:
            new = [command_line_flag, "$(value)"]

    elif "CommandLinePrefixFlag" in option:
        command_line_prefix_flag = option["CommandLinePrefixFlag"]
        new = [command_line_prefix_flag + "$(value)"]

    if new == None:
        fail("{name}: unable to extract value for {value} in {xcspec}\n\t{option}".format(
            name = name,
            value = repr(value),
            xcspec = xcspec,
            option = option,
        ))

    copts += [
        arg.replace("$(value)", v)
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

    id_map = {
        _CLANG: objc_copts,
        _SWIFT: swift_copts,
        _LD: linkopts,
        _MOMC: momc_copts,
        _MAPC: mapc_copts,
        _IBTOOL: ibtool_copts,
    }

    for setting in xcconfig:
        value = xcconfig[setting]
        for id in id_map:
            copts = id_map[id]
            option = SETTINGS[id]["Options"].get(setting)
            if option:
                _add_copts_from_option(id, option, value, copts, linkopts)

    return struct(
        objc_copts = objc_copts,
        cc_copts = cc_copts,
        swift_copts = swift_copts,
        momc_copts = momc_copts,
        mapc_copts = mapc_copts,
        ibtool_copts = ibtool_copts,
        linkopts = linkopts,
    )
