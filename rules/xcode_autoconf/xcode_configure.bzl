load("@bazel_tools//tools/osx:xcode_configure.bzl", "run_xcode_locator")

_EXECUTE_TIMEOUT = 10

def _search_sdk_output(output, sdkname):
    """Returns the sdk version given xcodebuild stdout and an sdkname."""
    return _search_string(output, "(%s" % sdkname, ")")


# This rule _must_ be fast as it's a `local` rule. `xcrun swift`
# is ~100-200ms
def _xcode_version_output(repository_ctx, name, version, aliases, developer_dir):
    """Returns a string containing an xcode_version build target."""
    build_contents = ""
    decorated_aliases = []
    error_msg = ""
    for alias in aliases:
        decorated_aliases.append("'%s'" % alias)
    xcodebuild_result = repository_ctx.execute(
        ["xcrun", "xcodebuild", "-version", "-sdk"],
        _EXECUTE_TIMEOUT,
        {"DEVELOPER_DIR": developer_dir},
    )
    if (xcodebuild_result.return_code != 0):
        error_msg = (
            "Invoking xcodebuild failed, developer dir: {devdir} ," +
            "return code {code}, stderr: {err}, stdout: {out}"
        ).format(
            devdir = developer_dir,
            code = xcodebuild_result.return_code,
            err = xcodebuild_result.stderr,
            out = xcodebuild_result.stdout,
        )
    ios_sdk_version = _search_sdk_output(xcodebuild_result.stdout, "iphoneos")
    tvos_sdk_version = _search_sdk_output(xcodebuild_result.stdout, "appletvos")
    macos_sdk_version = _search_sdk_output(xcodebuild_result.stdout, "macosx")
    watchos_sdk_version = _search_sdk_output(xcodebuild_result.stdout, "watchos")
    build_contents += "xcode_version(\n  name = '%s'," % name
    build_contents += "\n  version = '%s'," % version
    if aliases:
        build_contents += "\n  aliases = [%s]," % " ,".join(decorated_aliases)
    if ios_sdk_version:
        build_contents += "\n  default_ios_sdk_version = '%s'," % ios_sdk_version
    if tvos_sdk_version:
        build_contents += "\n  default_tvos_sdk_version = '%s'," % tvos_sdk_version
    if macos_sdk_version:
        build_contents += "\n  default_macos_sdk_version = '%s'," % macos_sdk_version
    if watchos_sdk_version:
        build_contents += "\n  default_watchos_sdk_version = '%s'," % watchos_sdk_version
    build_contents += "\n)\n"
    if error_msg:
        build_contents += "\n# Error: " + error_msg.replace("\n", " ") + "\n"
        print(error_msg)
    return build_contents


def _search_string(fullstring, prefix, suffix):
    """Returns the substring between two given substrings of a larger string.

    Args:
      fullstring: The larger string to search.
      prefix: The substring that should occur directly before the returned string.
      suffix: The substring that should occur directly after the returned string.
    Returns:
      A string occurring in fullstring exactly prefixed by prefix, and exactly
      terminated by suffix. For example, ("hello goodbye", "lo ", " bye") will
      return "good". If there is no such string, returns the empty string.
    """

    prefix_index = fullstring.find(prefix)
    if (prefix_index < 0):
        return ""
    result_start_index = prefix_index + len(prefix)
    suffix_index = fullstring.find(suffix, result_start_index)
    if (suffix_index < 0):
        return ""
    return fullstring[result_start_index:suffix_index]


def _run_darwin_xcode_configure(repository_ctx):
    """Evaluates local system state to create xcode_config and xcode_version targets."""
    env = repository_ctx.os.environ
    xcodebuild_result = repository_ctx.execute([
        "env",
        "-i",
        "DEVELOPER_DIR={}".format(env.get("DEVELOPER_DIR", default = "")),
        "xcrun",
        "xcodebuild",
        "-version",
    ], _EXECUTE_TIMEOUT)

    (toolchains, xcodeloc_err) = run_xcode_locator(
        repository_ctx,
        Label(repository_ctx.attr.xcode_locator),
    )

    if xcodeloc_err:
        fail("xcode-locator failed " +  str(xcodeloc_err))

    default_xcode_version = ""
    default_xcode_build_version = ""
    if xcodebuild_result.return_code == 0:
        default_xcode_version = _search_string(xcodebuild_result.stdout, "Xcode ", "\n")
        default_xcode_build_version = _search_string(
            xcodebuild_result.stdout,
            "Build version ",
            "\n",
        )
    default_xcode_target = ""
    target_names = []
    buildcontents = ""

    for toolchain in toolchains:
        version = toolchain.version
        aliases = toolchain.aliases
        developer_dir = toolchain.developer_dir
        target_name = "version%s" % version.replace(".", "_")
        buildcontents += _xcode_version_output(
            repository_ctx,
            target_name,
            version,
            aliases,
            developer_dir,
        )
        target_label = "':%s'" % target_name
        target_names.append(target_label)
        if (version.startswith(default_xcode_version) and
            version.endswith(default_xcode_build_version)):
            default_xcode_target = target_label
    buildcontents += "xcode_config(name = 'host_xcodes',"
    if target_names:
        buildcontents += "\n  versions = [%s]," % ", ".join(target_names)
    if not default_xcode_target and target_names:
        default_xcode_target = sorted(target_names, reverse = True)[0]
        print("No default Xcode version is set with 'xcode-select'; picking %s" %
              default_xcode_target)
    if default_xcode_target:
        buildcontents += "\n  default = %s," % default_xcode_target

    buildcontents += "\n)\n"
    buildcontents += "available_xcodes(name = 'host_available_xcodes',"
    if target_names:
        buildcontents += "\n  versions = [%s]," % ", ".join(target_names)
    if default_xcode_target:
        buildcontents += "\n  default = %s," % default_xcode_target
    buildcontents += "\n)\n"
    if repository_ctx.attr.remote_xcode:
        buildcontents += "xcode_config(name = 'all_xcodes',"
        buildcontents += "\n  remote_versions = '%s', " % repository_ctx.attr.remote_xcode
        buildcontents += "\n  local_versions = ':host_available_xcodes', "
        buildcontents += "\n)\n"
    return buildcontents

def _impl(repository_ctx):
    """Implementation for the local_config_xcode repository rule.

    Generates a BUILD file containing a root xcode_config target named 'host_xcodes',
    which points to an xcode_version target for each version of xcode installed on
    the local host machine. If no versions of xcode are present on the machine
    (for instance, if this is a non-darwin OS), creates a stub target.
    """
    os_name = repository_ctx.os.name.lower()
    if (os_name.startswith("mac os")):
        build_contents = """
        package(default_visibility = ['//visibility:public'])
        """
        build_contents += _run_darwin_xcode_configure(repository_ctx)
    else:
        build_contents = """
        package(default_visibility = ['//visibility:public'])
        xcode_config(name = 'host_xcodes')
        """
    repository_ctx.file("BUILD.bazel", build_contents)

xcode_autoconf = repository_rule(
    implementation = _impl,
    local = False,
    environ = ["DEVELOPER_DIR"],
    attrs = {
        # This remote xcode needs to be handled when remote caching is enabled
        "remote_xcode": attr.string(),
        "package_files": attr.label_list(default = [
            # Take a dependency on source files of the xcode configurator
            "@build_bazel_rules_ios//rules/xcode_autoconf:Package.swift",
            "@build_bazel_rules_ios//rules/xcode_autoconf:Sources/XcodeAutoConfigure/main.swift",
        ]),
    },
)
