load("//data:xcspecs.bzl", "SETTINGS")
load("@bazel_skylib//lib:types.bzl", "types")

_CLANG = "com.apple.compilers.llvm.clang.1_0"
_SWIFT = "com.apple.xcode.tools.swift.compiler"
_LD = "com.apple.pbx.linkers.ld"
_MOMC = "com.apple.compilers.model.coredata"
_MAPC = "com.apple.compilers.model.coredatamapping"
_IBTOOL = "com.apple.xcode.tools.ibtool.compiler"
_OTHERWISE = "<<otherwise>>"

def _unknown_enum_value(option, value, fatal = False):
    if option["Type"] != "Enumeration":
        return

    printer = fail if fatal else print

    printer("{name}: {value} not a valid value, must be one of {options}".format(
        name = option["Name"],
        value = repr(value),
        options = repr(option["Values"]),
    ))

def _id(value):
    return value

def _add_copts_from_option(xcspec, option, value, value_escaper, copts, linkopts):
    _type = option["Type"]
    name = option["Name"]

    if _type == "Boolean":
        if value not in ("YES", "NO"):
            coerced = "YES" if value != "0" else "NO"
            printer = print if types.is_string(value) else fail
            printer('{name}: {value} not a valid value, must be "YES" or "NO", inferred as {coerced}'.format(
                name = name,
                value = value,
                coerced = coerced,
            ))
            value = coerced
    elif _type == "Enumeration":
        if value not in option["Values"]:
            _unknown_enum_value(option, value)
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
        else:
            _unknown_enum_value(option, value, fatal = True)

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
            _unknown_enum_value(option, value, fatal = True)
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

    identifiers = [
        (_CLANG, objc_copts, _id),
        (_SWIFT, swift_copts, _id),
        (_LD, linkopts, _id),
        (_MOMC, momc_copts, _id),
        (_MAPC, mapc_copts, _id),
        (_IBTOOL, ibtool_copts, _id),
    ]

    for (id, copts, value_escaper) in identifiers:
        settings = SETTINGS[id]["Options"]
        for (setting, option) in settings.items():
            if not setting in xcconfig:
                continue

            value = xcconfig[setting]
            _add_copts_from_option(id, option, value, value_escaper, copts, linkopts)

    return struct(
        objc_copts = objc_copts,
        cc_copts = cc_copts,
        swift_copts = swift_copts,
        momc_copts = momc_copts,
        mapc_copts = mapc_copts,
        ibtool_copts = ibtool_copts,
        linkopts = linkopts,
    )
