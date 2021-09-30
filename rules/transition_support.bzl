"""Starlark transition support for Apple rules."""

def _current_apple_platform(apple_fragment, xcode_config):
    """Returns a struct containing the platform and target os version"""
    cpu = apple_fragment.single_arch_cpu
    platform = apple_fragment.single_arch_platform
    xcode_config = xcode_config[apple_common.XcodeVersionConfig]
    target_os_version = xcode_config.minimum_os_for_platform_type(
        platform.platform_type,
    )
    return struct(
        platform = platform,
        target_os_version = target_os_version,
    )

def _cpu_string(platform_type, settings):
    """Generates a <platform>_<arch> string for the current target based on the given parameters."""

    # If the cpu value has already been transformed to the correct value, we must not change it anymore.
    # Otherwise, we may build for the wrong arch.
    cpu_value = settings["//command_line_option:cpu"]
    if (platform_type == "macos" and cpu_value.startswith("{}_".format(platform_type))) or cpu_value.startswith("{}_".format(platform_type)):
        return cpu_value

    if platform_type == "ios":
        ios_cpus = settings["//command_line_option:ios_multi_cpus"]
        if ios_cpus:
            return "ios_{}".format(ios_cpus[0])
        return "ios_x86_64"
    if platform_type == "macos":
        macos_cpus = settings["//command_line_option:macos_cpus"]
        if macos_cpus:
            return "darwin_{}".format(macos_cpus[0])
        return "darwin_x86_64"
    if platform_type == "tvos":
        tvos_cpus = settings["//command_line_option:tvos_cpus"]
        if tvos_cpus:
            return "tvos_{}".format(tvos_cpus[0])
        return "tvos_x86_64"
    if platform_type == "watchos":
        watchos_cpus = settings["//command_line_option:watchos_cpus"]
        if watchos_cpus:
            return "watchos_{}".format(watchos_cpus[0])
        return "watchos_i386"

    fail("ERROR: Unknown platform type: {}".format(platform_type))

def _min_os_version_or_none(attr, platform, attr_platform_type):
    if attr_platform_type != platform:
        return None

    if hasattr(attr, "platforms"):
        platforms = attr.platforms
        value = platforms.get(platform)
        return value
    elif hasattr(attr, "minimum_os_version"):
        return attr.minimum_os_version
    else:
        fail("ERROR: must either specify a single platform/minimum_os_version, or specify a dict via platforms")

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

    ret = {
        "//command_line_option:apple configuration distinguisher": "applebin_" + platform_type,
        "//command_line_option:apple_platform_type": platform_type,
        "//command_line_option:apple_split_cpu": settings["//command_line_option:apple_split_cpu"],
        "//command_line_option:compiler": settings["//command_line_option:apple_compiler"],
        "//command_line_option:cpu": _cpu_string(platform_type, settings),
        "//command_line_option:crosstool_top": (
            settings["//command_line_option:apple_crosstool_top"]
        ),
        "//command_line_option:fission": [],
        "//command_line_option:grte_top": settings["//command_line_option:apple_grte_top"],
        "//command_line_option:ios_minimum_os": _min_os_version_or_none(attr, "ios", platform_type),
        "//command_line_option:macos_minimum_os": _min_os_version_or_none(attr, "macos", platform_type),
        "//command_line_option:tvos_minimum_os": _min_os_version_or_none(attr, "tvos", platform_type),
        "//command_line_option:watchos_minimum_os": _min_os_version_or_none(attr, "watchos", platform_type),
    }
    return ret

# These flags are a mix of options defined in native Bazel from the following fragments:
# - https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/analysis/config/CoreOptions.java
# - https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/rules/apple/AppleCommandLineOptions.java
# - https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/rules/cpp/CppOptions.java
_apple_rule_transition = transition(
    implementation = _apple_rule_transition_impl,
    inputs = [
        "//command_line_option:apple_compiler",
        "//command_line_option:apple_crosstool_top",
        "//command_line_option:apple_platform_type",
        "//command_line_option:apple_grte_top",
        "//command_line_option:cpu",
        "//command_line_option:ios_multi_cpus",
        "//command_line_option:macos_cpus",
        "//command_line_option:tvos_cpus",
        "//command_line_option:watchos_cpus",
        "//command_line_option:apple_split_cpu",
    ],
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
        "//command_line_option:tvos_minimum_os",
        "//command_line_option:watchos_minimum_os",
    ],
)

transition_support = struct(
    apple_rule_transition = _apple_rule_transition,
    current_apple_platform = _current_apple_platform,
)
