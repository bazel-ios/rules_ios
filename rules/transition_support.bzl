"""Starlark transition support for Apple rules."""

load(
    "@build_bazel_apple_support//configs:platforms.bzl",
    "CPU_TO_DEFAULT_PLATFORM_NAME",
)

_PLATFORM_TYPE_TO_CPUS_FLAG = {
    "ios": "//command_line_option:ios_multi_cpus",
    "macos": "//command_line_option:macos_cpus",
    "tvos": "//command_line_option:tvos_cpus",
    "visionos": "//command_line_option:visionos_cpus",
    "watchos": "//command_line_option:watchos_cpus",
}

_CPU_TO_DEFAULT_PLATFORM_FLAG = {
    cpu: "@build_bazel_apple_support//platforms:{}_platform".format(
        platform_name,
    )
    for cpu, platform_name in CPU_TO_DEFAULT_PLATFORM_NAME.items()
}

def _current_apple_platform(apple_fragment, xcode_config):
    """Returns a struct containing the platform and target os version"""
    platform = apple_fragment.single_arch_platform
    xcode_config = xcode_config[apple_common.XcodeVersionConfig]
    target_os_version = xcode_config.minimum_os_for_platform_type(
        platform.platform_type,
    )
    return struct(
        platform = platform,
        target_os_version = target_os_version,
    )

def _cpu_string(environment_arch, platform_type, settings):
    """Generates a <platform>_<arch> string for the current target based on the given parameters."""

    # If the cpu value has already been transformed to the correct value, we must not change it anymore.
    # Otherwise, we may build for the wrong arch.
    cpu_value = settings["//command_line_option:cpu"]
    if (platform_type == "macos" and cpu_value.startswith("%s_" % platform_type)) or cpu_value.startswith("%s_" % platform_type):
        return cpu_value

    if platform_type == "ios":
        if environment_arch:
            return "ios_{}".format(environment_arch)
        ios_cpus = settings["//command_line_option:ios_multi_cpus"]
        if ios_cpus:
            return "ios_{}".format(ios_cpus[0])
        cpu_value = settings["//command_line_option:cpu"]
        if cpu_value.startswith("ios_"):
            return cpu_value
        if cpu_value == "darwin_arm64":
            return "ios_sim_arm64"
        return "ios_x86_64"
    if platform_type == "visionos":
        if environment_arch:
            return "visionos_{}".format(environment_arch)
        visionos_cpus = settings["//command_line_option:visionos_cpus"]
        if visionos_cpus:
            return "visionos_{}".format(visionos_cpus[0])
        cpu_value = settings["//command_line_option:cpu"]
        if cpu_value.startswith("visionos_"):
            return cpu_value
        return "visionos_sim_arm64"
    if platform_type == "macos":
        if environment_arch:
            return "darwin_{}".format(environment_arch)
        macos_cpus = settings["//command_line_option:macos_cpus"]
        if macos_cpus:
            return "darwin_{}".format(macos_cpus[0])
        cpu_value = settings["//command_line_option:cpu"]
        if cpu_value.startswith("darwin_"):
            return cpu_value
        return "darwin_x86_64"
    if platform_type == "tvos":
        if environment_arch:
            return "tvos_{}".format(environment_arch)
        tvos_cpus = settings["//command_line_option:tvos_cpus"]
        if tvos_cpus:
            return "tvos_{}".format(tvos_cpus[0])
        return "tvos_x86_64"
    if platform_type == "watchos":
        if environment_arch:
            return "watchos_{}".format(environment_arch)
        watchos_cpus = settings["//command_line_option:watchos_cpus"]
        if watchos_cpus:
            return "watchos_{}".format(watchos_cpus[0])
        return "watchos_x86_64"

    fail("ERROR: Unknown platform type: {}".format(platform_type))

def _min_os_version_or_none(attr, attr_platforms, platform, attr_platform_type):
    if attr_platform_type != platform:
        return None

    if attr_platforms != None:
        return attr_platforms[platform] if (platform in attr_platforms and attr_platforms[platform] != "") else None

    if hasattr(attr, "minimum_os_version"):
        return attr.minimum_os_version if attr.minimum_os_version != "" else None

    return None

def _apple_platforms_base_values(settings, platform_type):
    cpu = _cpu_string(
        environment_arch = None,
        platform_type = platform_type,
        settings = settings,
    )
    apple_platforms_value = settings["//command_line_option:apple_platforms"]
    apple_platforms = apple_platforms_value if apple_platforms_value else []
    return {
        "//command_line_option:apple_platforms": apple_platforms,
        "//command_line_option:platforms": [apple_platforms[0]] if apple_platforms else [settings[_CPU_TO_DEFAULT_PLATFORM_FLAG[cpu]]],
    }

def _apple_rule_transition_impl(settings, attr):
    """Rule transition for Apple rules."""
    platform_type = str(settings["//command_line_option:apple_platform_type"])
    attr_platform_type = getattr(attr, "platform_type", None)
    attr_platforms = getattr(attr, "platforms", None)
    fail_on_apple_rule_transition_platform_mismatches = getattr(attr, "fail_on_apple_rule_transition_platform_mismatches", False)
    if attr_platform_type and attr_platform_type != platform_type:
        if fail_on_apple_rule_transition_platform_mismatches:
            fail("ERROR: {}: attribute platform_type set to {}, but inferred to be {}".format(attr.name, attr_platform_type, platform_type))
        platform_type = attr_platform_type

    if attr_platforms and platform_type not in attr_platforms:
        if fail_on_apple_rule_transition_platform_mismatches:
            fail("ERROR: {}: attribute platforms set to {}, but platform inferred to be {}".format(attr.name, attr_platforms, platform_type))
        platform_type = attr_platforms.keys()[0]

    cpu_string = _cpu_string(None, platform_type, settings)

    # Transition ios_multi_cpus to to a single cpu when building for iOS.
    # Rules using this transition (e.g., apple_framework_packaging, precompiled_apple_resource_bundle) don't need any artifacts from other archs.
    ios_multi_cpus = cpu_string[4:] if platform_type == "ios" else settings["//command_line_option:ios_multi_cpus"]

    ret = {
        "//command_line_option:apple configuration distinguisher": "applebin_" + platform_type,
        "//command_line_option:apple_platform_type": platform_type,
        "//command_line_option:apple_split_cpu": settings["//command_line_option:apple_split_cpu"],
        "//command_line_option:compiler": None,
        "//command_line_option:cpu": cpu_string,
        "//command_line_option:crosstool_top": (
            settings["//command_line_option:apple_crosstool_top"]
        ),
        "//command_line_option:fission": [],
        "//command_line_option:grte_top": None,
        "//command_line_option:ios_minimum_os": _min_os_version_or_none(attr, attr_platforms, "ios", platform_type),
        "//command_line_option:ios_multi_cpus": ios_multi_cpus,
        "//command_line_option:macos_minimum_os": _min_os_version_or_none(attr, attr_platforms, "macos", platform_type),
        "//command_line_option:tvos_minimum_os": _min_os_version_or_none(attr, attr_platforms, "tvos", platform_type),
        "//command_line_option:watchos_minimum_os": _min_os_version_or_none(attr, attr_platforms, "watchos", platform_type),
    }
    ret.update(_apple_platforms_base_values(settings, platform_type))
    return ret

_supports_visionos = hasattr(apple_common.platform_type, "visionos")

# These flags are a mix of options defined in native Bazel from the following fragments:
# - https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/analysis/config/CoreOptions.java
# - https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/rules/apple/AppleCommandLineOptions.java
# - https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/rules/cpp/CppOptions.java
_apple_rule_transition = transition(
    implementation = _apple_rule_transition_impl,
    inputs = [
        "//command_line_option:apple_crosstool_top",
        "//command_line_option:apple_platform_type",
        "//command_line_option:cpu",
        "//command_line_option:ios_multi_cpus",
        "//command_line_option:macos_cpus",
        "//command_line_option:tvos_cpus",
        "//command_line_option:watchos_cpus",
        "//command_line_option:apple_split_cpu",
        "//command_line_option:macos_minimum_os",
        "//command_line_option:apple_platforms",
    ] + (
        ["//command_line_option:visionos_cpus"] if _supports_visionos else []
    ) + _CPU_TO_DEFAULT_PLATFORM_FLAG.values(),
    outputs = [
        "//command_line_option:apple configuration distinguisher",
        "//command_line_option:apple_platform_type",
        "//command_line_option:apple_split_cpu",
        "//command_line_option:compiler",
        "//command_line_option:cpu",
        "//command_line_option:crosstool_top",
        "//command_line_option:fission",
        "//command_line_option:grte_top",
        "//command_line_option:ios_minimum_os",
        "//command_line_option:ios_multi_cpus",
        "//command_line_option:macos_minimum_os",
        "//command_line_option:tvos_minimum_os",
        "//command_line_option:watchos_minimum_os",
        "//command_line_option:apple_platforms",
        "//command_line_option:platforms",
    ],
)

def _is_arch_supported_for_target_tuple(*, environment_arch, minimum_os_version, platform_type):
    """Indicates if the environment_arch selected is supported for the given platform and min os."""
    if minimum_os_version == "":
        return True
    dotted_minimum_os_version = apple_common.dotted_version(minimum_os_version)
    if (environment_arch == "armv7k" and platform_type == "watchos" and
        dotted_minimum_os_version >= apple_common.dotted_version("9.0")):
        return False
    return True

def _platform_specific_cpu_setting_name(platform_type):
    """Returns the name of a platform-specific CPU setting."""
    flag = _PLATFORM_TYPE_TO_CPUS_FLAG.get(platform_type, None)
    if not flag:
        fail("ERROR: Unknown platform type: {}".format(platform_type))
    return flag

def _environment_archs(platform_type, settings):
    """Returns a full set of environment archs from the incoming command line options."""
    environment_archs = settings[_platform_specific_cpu_setting_name(platform_type)]
    if not environment_archs:
        if platform_type == "ios":
            # Legacy exception to interpret the --cpu as an iOS arch.
            cpu_value = settings["//command_line_option:cpu"]
            if cpu_value.startswith("ios_"):
                environment_archs = [cpu_value[4:]]
        if not environment_archs:
            environment_archs = [
                _cpu_string(
                    environment_arch = None,
                    platform_type = platform_type,
                    settings = settings,
                ).split("_", 1)[1],
            ]
    return environment_archs

def _split_transition_impl(settings, attr):
    """Basic split transition for Apple platform-aware rules.

    This has to interop with the other rules and transitions to ensure we have
    matching settings."""

    split_output_dictionary = {}
    invalid_requested_archs = []
    emit_swiftinterface = hasattr(attr, "_emitswiftinterface")
    platform_type = attr.platform_type

    # Insert platform types based on the CPU
    if platform_type == "":
        cpu = settings["//command_line_option:cpu"]
        if cpu.startswith("ios"):
            platform_type = "ios"
        elif cpu.startswith("tvos"):
            platform_type = "tvos"
        elif cpu.startswith("watchos"):
            platform_type = "watchos"
        elif cpu.startswith("visionos"):
            platform_type = "visionos"
        else:
            platform_type = "macos"

    for environment_arch in _environment_archs(platform_type, settings):
        found_cpu = _cpu_string(
            environment_arch = environment_arch,
            platform_type = platform_type,
            settings = settings,
        )
        if found_cpu in split_output_dictionary:
            continue

        minimum_os_version = attr.minimum_os_version
        environment_arch_is_supported = _is_arch_supported_for_target_tuple(
            environment_arch = environment_arch,
            minimum_os_version = minimum_os_version,
            platform_type = platform_type,
        )
        if not environment_arch_is_supported:
            invalid_requested_arch = {
                "environment_arch": environment_arch,
                "minimum_os_version": minimum_os_version,
                "platform_type": platform_type,
            }
            invalid_requested_archs.append(invalid_requested_arch)
            continue

        cpu_string = _cpu_string(environment_arch, platform_type, settings)
        ios_multi_cpus = cpu_string[4:] if platform_type == "ios" else settings["//command_line_option:ios_multi_cpus"]
        attr_platforms = getattr(attr, "platforms", None)
        output_dictionary = {
            "//command_line_option:apple configuration distinguisher": "applebin_" + platform_type,
            "//command_line_option:apple_platform_type": platform_type,
            "//command_line_option:apple_split_cpu": environment_arch if (environment_arch and environment_arch != "") else None,
            "//command_line_option:compiler": None,
            "//command_line_option:cpu": _cpu_string(
                environment_arch = None,
                platform_type = platform_type,
                settings = settings,
            ),
            "//command_line_option:crosstool_top": (
                settings["//command_line_option:apple_crosstool_top"]
            ),
            "//command_line_option:fission": [],
            "//command_line_option:grte_top": None,
            "//command_line_option:ios_minimum_os": _min_os_version_or_none(attr, attr_platforms, "ios", platform_type),
            "//command_line_option:ios_multi_cpus": ios_multi_cpus,
            "//command_line_option:macos_minimum_os": _min_os_version_or_none(attr, attr_platforms, "macos", platform_type),
            "//command_line_option:tvos_minimum_os": _min_os_version_or_none(attr, attr_platforms, "tvos", platform_type),
            "//command_line_option:watchos_minimum_os": _min_os_version_or_none(attr, attr_platforms, "watchos", platform_type),
            "//command_line_option:minimum_os_version": minimum_os_version,
        }
        output_dictionary.update(_apple_platforms_base_values(settings, platform_type))
        output_dictionary["@build_bazel_rules_swift//swift:emit_swiftinterface"] = emit_swiftinterface
        split_output_dictionary[found_cpu] = output_dictionary

    if not bool(split_output_dictionary):
        error_msg = "Could not find any valid architectures to build for the current target.\n\n"
        if invalid_requested_archs:
            error_msg += "Requested the following invalid architectures:\n"
            for invalid_requested_arch in invalid_requested_archs:
                error_msg += (
                    " - {environment_arch} for {platform_type} {minimum_os_version}\n".format(
                        **invalid_requested_arch
                    )
                )
            error_msg += (
                "\nPlease check that the specified architectures are valid for the target's " +
                "specified minimum_os_version.\n"
            )
        fail(error_msg)
    return split_output_dictionary

_split_transition = transition(
    implementation = _split_transition_impl,
    inputs = [
                 "//command_line_option:cpu",
                 "//command_line_option:apple_crosstool_top",
                 "//command_line_option:ios_multi_cpus",
                 "//command_line_option:macos_cpus",
                 "//command_line_option:tvos_cpus",
                 "//command_line_option:watchos_cpus",
                 "//command_line_option:minimum_os_version",
                 "//command_line_option:apple_platforms",
             ] + (["//command_line_option:visionos_cpus"] if _supports_visionos else []) +
             _CPU_TO_DEFAULT_PLATFORM_FLAG.values(),
    outputs = [
        "//command_line_option:apple configuration distinguisher",
        "//command_line_option:apple_platform_type",
        "//command_line_option:apple_split_cpu",
        "//command_line_option:compiler",
        "//command_line_option:cpu",
        "//command_line_option:crosstool_top",
        "//command_line_option:fission",
        "//command_line_option:grte_top",
        "//command_line_option:ios_minimum_os",
        "//command_line_option:macos_minimum_os",
        "//command_line_option:ios_multi_cpus",
        "//command_line_option:minimum_os_version",
        "//command_line_option:tvos_minimum_os",
        "//command_line_option:watchos_minimum_os",
        "//command_line_option:apple_platforms",
        "//command_line_option:platforms",
        "@build_bazel_rules_swift//swift:emit_swiftinterface",
    ],
)

transition_support = struct(
    apple_rule_transition = _apple_rule_transition,
    split_transition = _split_transition,
    current_apple_platform = _current_apple_platform,
)
