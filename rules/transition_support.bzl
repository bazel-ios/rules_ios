"""
Starlark transition support for Apple rules.

This module makes the following distinctions around Apple CPU-adjacent values for clarity, based in
part on the language used for XCFramework library identifiers:

- `architecture`s or "arch"s represent the type of binary slice ("arm64", "x86_64").

- `environment`s represent a platform variant ("device", "sim"). These sometimes appear in the "cpu"
    keys out of necessity to distinguish new "cpu"s from an existing Apple "cpu" when a new
    Crosstool-provided toolchain is established.

- `platform_type`s represent the Apple OS being built for ("ios", "macos", "tvos", "visionos",
    "watchos").

- `cpu`s are keys to match a Crosstool-provided toolchain ("ios_sim_arm64", "ios_x86_64").
    Essentially it is a raw key that implicitly references the other three values for the purpose of
    getting the right Apple toolchain to build outputs with from the Apple Crosstool.
"""

# NOTE: this is essentially a copy of transition_support from rules_apple.
#       see the `PATCH:` comments for the changes made to the original file.

load(
    "@build_bazel_apple_support//configs:platforms.bzl",
    "CPU_TO_DEFAULT_PLATFORM_NAME",
)
load(
    "@build_bazel_rules_apple//apple/build_settings:build_settings.bzl",
    "build_settings_labels",
)

_supports_visionos = hasattr(apple_common.platform_type, "visionos")
_is_bazel_7 = not hasattr(apple_common, "apple_crosstool_transition")

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

# PATCH: start - this function is specific to rules_ios
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

# PATCH: end

# PATCH: start - private helper to get the `platform_type` from the rules_ios attributes.
def _rules_ios_platform_type(settings, attr):
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

    if not platform_type:
        fail("ERROR: platform_type not found")

    return platform_type

# PATCH: end

# PATCH: start - private helper to get the `minimum_os_version` from the rules_ios attributes.
def _rules_ios_minimum_os_version(platform_type, attr):
    platforms = getattr(attr, "platforms", None)

    if platforms:
        return platforms[platform_type] if (platform_type in platforms and platforms[platform_type] != "") else None

    if hasattr(attr, "minimum_os_version"):
        return attr.minimum_os_version if attr.minimum_os_version != "" else None

    return None

# PATCH: end

def _platform_specific_cpu_setting_name(platform_type):
    """Returns the name of a platform-specific CPU setting.

    Args:
        platform_type: A string denoting the platform type; `"ios"`, `"macos"`, `"tvos"`,
            "visionos", or `"watchos"`.

    Returns:
        The `"//command_line_option:..."` string that is used as the key for the CPUs flag of the
            given platform in settings dictionaries. This function never returns `None`; if the
            platform type is invalid, the build fails.
    """
    flag = _PLATFORM_TYPE_TO_CPUS_FLAG.get(platform_type, None)
    if not flag:
        fail("ERROR: Unknown platform type: {}".format(platform_type))
    return flag

def _environment_archs(platform_type, settings):
    """Returns a full set of environment archs from the incoming command line options.

    Args:
        platform_type: A string denoting the platform type; `"ios"`, `"macos"`,
            `"tvos"`, `"visionos"`, or `"watchos"`.
        settings: A dictionary whose set of keys is defined by the inputs parameter, typically from
            the settings argument found on the implementation function of the current Starlark
            transition.

    Returns:
        A list of valid Apple environments with its architecture as a string (for example
        `sim_arm64` from `ios_sim_arm64`, or `arm64` from `ios_arm64`).
    """
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

def _cpu_string(*, environment_arch, platform_type, settings = {}):
    """Generates a <platform>_<environment?>_<arch> string for the current target based on args.

    Args:
        environment_arch: A valid Apple environment when applicable with its architecture as a
            string (for example `sim_arm64` from `ios_sim_arm64`, or `arm64` from `ios_arm64`), or
            None to infer a value from command line options passed through settings.
        platform_type: The Apple platform for which the rule should build its targets (`"ios"`,
            `"macos"`, `"tvos"`, `"visionos"`, or `"watchos"`).
        settings: A dictionary whose set of keys is defined by the inputs parameter, typically from
            the settings argument found on the implementation function of the current Starlark
            transition. If not defined, defaults to an empty dictionary. Used as a fallback if the
            `environment_arch` argument is None.

    Returns:
        A <platform>_<arch> string defined for the current target.
    """
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

def _min_os_version_or_none(*, minimum_os_version, platform, platform_type):
    if platform_type == platform:
        return minimum_os_version
    return None

def _is_arch_supported_for_target_tuple(*, environment_arch, minimum_os_version, platform_type):
    """Indicates if the environment_arch selected is supported for the given platform and min os.

    Args:
        environment_arch: A valid Apple environment when applicable with its architecture as a
            string (for example `sim_arm64` from `ios_sim_arm64`, or `arm64` from `ios_arm64`), or
            None to infer a value from command line options passed through settings.
        minimum_os_version: A string representing the minimum OS version specified for this
            platform, represented as a dotted version number (for example, `"9.0"`).
        platform_type: The Apple platform for which the rule should build its targets (`"ios"`,
            `"macos"`, `"tvos"`, `"visionos"`, or `"watchos"`).

    Returns:
        True if the architecture is supported for the given config, False otherwise.
    """

    # PATCH: start - this returns true when the minimum_os_version is empty in rules_ios
    if not minimum_os_version:
        return True

    # PATCH: end

    dotted_minimum_os_version = apple_common.dotted_version(minimum_os_version)

    if (environment_arch == "armv7k" and platform_type == "watchos" and
        dotted_minimum_os_version >= apple_common.dotted_version("9.0")):
        return False

    return True

def _command_line_options(
        *,
        apple_platforms = [],
        emit_swiftinterface = False,
        environment_arch = None,
        force_bundle_outputs = False,
        minimum_os_version,
        platform_type,
        settings):
    """Generates a dictionary of command line options suitable for the current target.

    Args:
        apple_platforms: A list of labels referencing platforms if any should be set by the current
            rule. This will be applied directly to `apple_platforms` to allow for forwarding
            multiple platforms to rules evaluated after the transition is applied, and only the
            first element will be applied to `platforms` as that will be what is resolved by the
            underlying rule. Defaults to an empty list, which will signal to Bazel that platform
            mapping can take place as a fallback measure.
        emit_swiftinterface: Wheither to emit swift interfaces for the given target. Defaults to
            `False`.
        environment_arch: A valid Apple environment when applicable with its architecture as a
            string (for example `sim_arm64` from `ios_sim_arm64`, or `arm64` from `ios_arm64`), or
            None to infer a value from command line options passed through settings.
        force_bundle_outputs: Indicates if the rule should always emit tree artifact outputs, which
            are effectively bundles that aren't enclosed within a zip file (ipa). If not `True`,
            this will be set to the incoming value instead. Defaults to `False`.
        minimum_os_version: A string representing the minimum OS version specified for this
            platform, represented as a dotted version number (for example, `"9.0"`).
        platform_type: The Apple platform for which the rule should build its targets (`"ios"`,
            `"macos"`, `"tvos"`, `"visionos"`, or `"watchos"`).
        settings: A dictionary whose set of keys is defined by the inputs parameter, typically from
            the settings argument found on the implementation function of the current Starlark
            transition.

    Returns:
        A dictionary of `"//command_line_option"`s defined for the current target.
    """
    cpu = _cpu_string(
        environment_arch = environment_arch,
        platform_type = platform_type,
        settings = settings,
    )

    default_platforms = [settings[_CPU_TO_DEFAULT_PLATFORM_FLAG[cpu]]] if _is_bazel_7 else []
    return {
        build_settings_labels.use_tree_artifacts_outputs: force_bundle_outputs if force_bundle_outputs else settings[build_settings_labels.use_tree_artifacts_outputs],
        "//command_line_option:apple configuration distinguisher": "applebin_" + platform_type,
        "//command_line_option:apple_platform_type": platform_type,
        "//command_line_option:apple_platforms": apple_platforms,
        # `apple_split_cpu` is used by the Bazel Apple configuration distinguisher to distinguish
        # architecture and environment, therefore we set `environment_arch` when it is available.
        "//command_line_option:apple_split_cpu": environment_arch if environment_arch else "",
        "//command_line_option:compiler": None,
        "//command_line_option:cpu": cpu,
        "//command_line_option:crosstool_top": (
            settings["//command_line_option:apple_crosstool_top"]
        ),
        "//command_line_option:fission": [],
        "//command_line_option:grte_top": None,
        "//command_line_option:platforms": [apple_platforms[0]] if apple_platforms else default_platforms,
        "//command_line_option:ios_minimum_os": _min_os_version_or_none(
            minimum_os_version = minimum_os_version,
            platform = "ios",
            platform_type = platform_type,
        ),
        "//command_line_option:macos_minimum_os": _min_os_version_or_none(
            minimum_os_version = minimum_os_version,
            platform = "macos",
            platform_type = platform_type,
        ),
        "//command_line_option:minimum_os_version": minimum_os_version,
        "//command_line_option:tvos_minimum_os": _min_os_version_or_none(
            minimum_os_version = minimum_os_version,
            platform = "tvos",
            platform_type = platform_type,
        ),
        "//command_line_option:watchos_minimum_os": _min_os_version_or_none(
            minimum_os_version = minimum_os_version,
            platform = "watchos",
            platform_type = platform_type,
        ),
        "@build_bazel_rules_swift//swift:emit_swiftinterface": emit_swiftinterface,
    }

def _apple_rule_base_transition_impl(settings, attr):
    """Rule transition for Apple rules using Bazel CPUs and a valid Apple split transition."""

    # PATCH: start - The following grabs the platform_type and minimum_os_version from the rules_ios attrs.
    platform_type = _rules_ios_platform_type(settings, attr)
    minimum_os_version = _rules_ios_minimum_os_version(platform_type, attr)
    # PATCH: end

    return _command_line_options(
        emit_swiftinterface = hasattr(attr, "_emitswiftinterface"),
        environment_arch = _environment_archs(platform_type, settings)[0],
        minimum_os_version = minimum_os_version,
        platform_type = platform_type,
        settings = settings,
    )

# These flags are a mix of options defined in native Bazel from the following fragments:
# - https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/analysis/config/CoreOptions.java
# - https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/rules/apple/AppleCommandLineOptions.java
# - https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/rules/cpp/CppOptions.java
_apple_rule_common_transition_inputs = [
    build_settings_labels.use_tree_artifacts_outputs,
    "//command_line_option:apple_crosstool_top",
] + _CPU_TO_DEFAULT_PLATFORM_FLAG.values()
_apple_rule_base_transition_inputs = _apple_rule_common_transition_inputs + [
    "//command_line_option:apple_platform_type",
    "//command_line_option:cpu",
    "//command_line_option:ios_multi_cpus",
    "//command_line_option:macos_cpus",
    "//command_line_option:tvos_cpus",
    "//command_line_option:watchos_cpus",
] + (["//command_line_option:visionos_cpus"] if _supports_visionos else [])
_apple_platforms_rule_base_transition_inputs = _apple_rule_base_transition_inputs + [
    "//command_line_option:apple_platforms",
    "//command_line_option:incompatible_enable_apple_toolchain_resolution",
]
_apple_platform_transition_inputs = _apple_platforms_rule_base_transition_inputs + [
    "//command_line_option:platforms",
]
_apple_rule_base_transition_outputs = [
    build_settings_labels.use_tree_artifacts_outputs,
    "//command_line_option:apple configuration distinguisher",
    "//command_line_option:apple_platform_type",
    "//command_line_option:apple_platforms",
    "//command_line_option:apple_split_cpu",
    "//command_line_option:compiler",
    "//command_line_option:cpu",
    "//command_line_option:crosstool_top",
    "//command_line_option:fission",
    "//command_line_option:grte_top",
    "//command_line_option:ios_minimum_os",
    "//command_line_option:macos_minimum_os",
    "//command_line_option:minimum_os_version",
    "//command_line_option:platforms",
    "//command_line_option:tvos_minimum_os",
    "//command_line_option:watchos_minimum_os",
    "@build_bazel_rules_swift//swift:emit_swiftinterface",
]

_apple_rule_base_transition = transition(
    implementation = _apple_rule_base_transition_impl,
    inputs = _apple_rule_base_transition_inputs,
    outputs = _apple_rule_base_transition_outputs,
)

def _apple_platform_split_transition_impl(settings, attr):
    """Starlark 1:2+ transition for Apple platform-aware rules"""
    output_dictionary = {}
    invalid_requested_archs = []

    # PATCH: start - The following grabs the platform_type and minimum_os_version from the rules_ios attrs.
    platform_type = _rules_ios_platform_type(settings, attr)
    minimum_os_version = _rules_ios_minimum_os_version(platform_type, attr)
    # PATCH: end

    # iOS and tvOS static frameworks require underlying swift_library targets generate a Swift
    # interface file. These rules define a private attribute called `_emitswiftinterface` that
    # let's this transition flip rules_swift config down the build graph.
    emit_swiftinterface = hasattr(attr, "_emitswiftinterface")

    if settings["//command_line_option:incompatible_enable_apple_toolchain_resolution"]:
        platforms = (
            settings["//command_line_option:apple_platforms"] or
            settings["//command_line_option:platforms"]
        )
        # Currently there is no "default" platform for Apple-based platforms. If necessary, a
        # default platform could be generated for the rule's underlying platform_type, but for now
        # we work with the assumption that all users of the rules should set an appropriate set of
        # platforms when building Apple targets with `apple_platforms`.

        for index, platform in enumerate(platforms):
            # Create a new, reordered list so that the platform we need to resolve is always first,
            # and the other platforms will follow.
            apple_platforms = list(platforms)
            platform_to_resolve = apple_platforms.pop(index)
            apple_platforms.insert(0, platform_to_resolve)

            if str(platform) not in output_dictionary:
                output_dictionary[str(platform)] = _command_line_options(
                    apple_platforms = apple_platforms,
                    emit_swiftinterface = emit_swiftinterface,
                    minimum_os_version = minimum_os_version,
                    platform_type = platform_type,
                    settings = settings,
                )

    else:
        for environment_arch in _environment_archs(platform_type, settings):
            found_cpu = _cpu_string(
                environment_arch = environment_arch,
                platform_type = platform_type,
                settings = settings,
            )
            if found_cpu in output_dictionary:
                continue

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

                # NOTE: This logic to filter unsupported Apple CPUs would be good to implement on
                # the platforms side, but it is presently not possible as constraint resolution
                # cannot be performed within a transition.
                #
                # Propagate a warning to the user so that the dropped arch becomes actionable.
                # buildifier: disable=print
                print(
                    ("Warning: The architecture {environment_arch} is not valid for " +
                     "{platform_type} with a minimum OS of {minimum_os_version}. This " +
                     "architecture will be ignored in this build. This will be an error in a " +
                     "future version of the Apple rules. Please address this in your build " +
                     "invocation.").format(
                        **invalid_requested_arch
                    ),
                )
                invalid_requested_archs.append(invalid_requested_arch)
                continue

            output_dictionary[found_cpu] = _command_line_options(
                emit_swiftinterface = emit_swiftinterface,
                environment_arch = environment_arch,
                minimum_os_version = minimum_os_version,
                platform_type = platform_type,
                settings = settings,
            )

    if not bool(output_dictionary):
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

    return output_dictionary

_apple_platform_split_transition = transition(
    implementation = _apple_platform_split_transition_impl,
    inputs = _apple_platform_transition_inputs,
    outputs = _apple_rule_base_transition_outputs,
)

transition_support = struct(
    apple_platform_split_transition = _apple_platform_split_transition,
    apple_rule_transition = _apple_rule_base_transition,
    current_apple_platform = _current_apple_platform,
)
