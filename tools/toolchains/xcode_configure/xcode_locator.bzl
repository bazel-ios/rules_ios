_EXECUTE_TIMEOUT = 120

def search_string(fullstring, prefix, suffix):
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

def _search_sdk_output(output, sdkname):
    """Returns the sdk version given xcodebuild stdout and an sdkname."""
    return search_string(output, "(%s" % sdkname, ")")

def _xcode_versions(repository_ctx, developer_dir):
    xcodebuild_result = repository_ctx.execute(
        ["xcrun", "xcodebuild", "-version", "-sdk"],
        _EXECUTE_TIMEOUT,
        {"DEVELOPER_DIR": developer_dir},
    )
    error_msg = ""
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
        fail(error_msg)

    ios_sdk_version = _search_sdk_output(xcodebuild_result.stdout, "iphoneos")
    tvos_sdk_version = _search_sdk_output(xcodebuild_result.stdout, "appletvos")
    macos_sdk_version = _search_sdk_output(xcodebuild_result.stdout, "macosx")
    watchos_sdk_version = _search_sdk_output(xcodebuild_result.stdout, "watchos")
    return ios_sdk_version, tvos_sdk_version, macos_sdk_version, watchos_sdk_version

def xcode_version_dict(repository_ctx, developer_dir):
    ios_sdk_version, tvos_sdk_version, macos_sdk_version, watchos_sdk_version = _xcode_versions(repository_ctx, developer_dir)
    return {
        "ios": ios_sdk_version,
        "tvos": tvos_sdk_version,
        "macos": macos_sdk_version,
        "watchos": watchos_sdk_version,
    }

def xcode_version_output(repository_ctx, name, version, aliases, developer_dir):
    """Returns a string containing an xcode_version build target."""
    build_contents = ""
    decorated_aliases = []
    for alias in aliases:
        decorated_aliases.append("'%s'" % alias)
    ios_sdk_version, tvos_sdk_version, macos_sdk_version, watchos_sdk_version = _xcode_versions(repository_ctx, developer_dir)
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
    return build_contents

def run_xcode_locator(repository_ctx, xcode_locator_src_label):
    """Generates xcode-locator from source and runs it.

    Builds xcode-locator in the current repository directory.
    Returns the standard output of running xcode-locator with -v, which will
    return information about locally installed Xcode toolchains and the versions
    they are associated with.

    This should only be invoked on a darwin OS, as xcode-locator cannot be built
    otherwise.

    Args:
      repository_ctx: The repository context.
      xcode_locator_src_label: The label of the source file for xcode-locator.
    Returns:
      A list representing installed xcode toolchain information. Each
      element of the list is a struct containing information for one installed
      toolchain. This is an empty list if there was an error building or
      running xcode-locator.
    """
    xcodeloc_src_path = str(repository_ctx.path(xcode_locator_src_label))
    env = repository_ctx.os.environ
    xcrun_result = repository_ctx.execute([
        "env",
        "-i",
        "DEVELOPER_DIR={}".format(env.get("DEVELOPER_DIR", default = "")),
        "xcrun",
        "--sdk",
        "macosx",
        "clang",
        "-mmacosx-version-min=10.9",
        "-fobjc-arc",
        "-framework",
        "CoreServices",
        "-framework",
        "Foundation",
        "-o",
        "xcode-locator-bin",
        xcodeloc_src_path,
    ], _EXECUTE_TIMEOUT)

    if (xcrun_result.return_code != 0):
        suggestion = ""
        if "Agreeing to the Xcode/iOS license" in xcrun_result.stderr:
            suggestion = ("(You may need to sign the xcode license." +
                          " Try running 'sudo xcodebuild -license')")
        error_msg = (
            "Generating xcode-locator-bin failed. {suggestion} " +
            "return code {code}, stderr: {err}, stdout: {out}"
        ).format(
            suggestion = suggestion,
            code = xcrun_result.return_code,
            err = xcrun_result.stderr,
            out = xcrun_result.stdout,
        )
        fail(error_msg.replace("\n", " "))

    xcode_locator_result = repository_ctx.execute(
        ["./xcode-locator-bin", "-v"],
        _EXECUTE_TIMEOUT,
    )
    if (xcode_locator_result.return_code != 0):
        error_msg = (
            "Invoking xcode-locator failed, " +
            "return code {code}, stderr: {err}, stdout: {out}"
        ).format(
            code = xcode_locator_result.return_code,
            err = xcode_locator_result.stderr,
            out = xcode_locator_result.stdout,
        )

        fail(error_msg.replace("\n", " "))
    xcode_toolchains = []

    # xcode_dump is comprised of newlines with different installed xcode versions,
    # each line of the form <version>:<comma_separated_aliases>:<developer_dir>.
    xcode_dump = xcode_locator_result.stdout
    for xcodeversion in xcode_dump.split("\n"):
        if ":" in xcodeversion:
            infosplit = xcodeversion.split(":")
            toolchain = struct(
                version = infosplit[0],
                aliases = infosplit[1].split(","),
                developer_dir = infosplit[2],
            )
            xcode_toolchains.append(toolchain)
    return xcode_toolchains
