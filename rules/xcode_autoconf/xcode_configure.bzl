# This rule _must_ be fast as it's a `local` rule. `xcrun swift`
# is ~100-200ms
def _run_darwin_xcode_configure(repository_ctx):
    execute_timeout = 10
    xcrun_result = repository_ctx.execute([
        "xcrun",
        "swift",
        "run",

        # Swift run needs a build path to compile sources. Set it adjacent to
        # this directory, so we don't re-recompile it everytime.
        "--build-path",
        "../xcode_autoconf_build_dir",
        "--configuration",
        "release",

        # Set this directory to the directory of package file
        "--package-path",
        repository_ctx.path(repository_ctx.attr.package_files[0]).dirname,
        "XcodeAutoConfigure",
    ], execute_timeout)

    if xcrun_result.return_code != 0:
        fail("Failed to auto_configure", xcrun_result.stdout, xcrun_result.stderr)

def _impl(repository_ctx):
    """Implementation for the local_config_xcode repository rule.

    Generates a BUILD file containing a root xcode_config target named 'host_xcodes',
    which points to an xcode_version target for each version of xcode installed on
    the local host machine. If no versions of xcode are present on the machine
    (for instance, if this is a non-darwin OS), creates a stub target.
    """
    os_name = repository_ctx.os.name.lower()
    if (os_name.startswith("mac os")):
        _run_darwin_xcode_configure(repository_ctx)
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
