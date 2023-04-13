"""This file contains rules to build framework binaries from your podfile or cartfile"""

verbose_default = False  # The default verbose level when running this rules
timeout_default = 600 * 2  # Execution timeout for prebuilding frameworks (in seconds)

def _make_framework_filegroup(ctx, framework_path):
    """Generate the filegroup information of the framework"""

    relative_path = str(framework_path).replace(str(ctx.path(".")) + "/", "")
    name = framework_path.basename.replace(".framework", "")

    new_content = """\
filegroup(
    name = "%s",
    srcs = glob(["%s/**/*"]),
    visibility = ["//visibility:public"],
)\
""" % (name, relative_path)

    return new_content

def _copy_files(ctx, files):
    """Copy the specified files to the root this repository rule"""

    destination = ctx.path(".")
    for file in files:
        _execute(ctx, "cp -r \"%s\" \"%s\"" % (file, destination))

def _execute(ctx, cmd):
    """Execute the specified command"""

    result = ctx.execute(["sh", "-c", cmd], quiet = not ctx.attr.verbose, timeout = ctx.attr.timeout)
    if result.return_code != 0:
        fail(
            """
====== Command '%s' failed (%s) ======
====== stdout ======
%s
====== stderr ======
%s
        """ % (cmd, result.return_code, result.stdout, result.stderr),
        )
    return result.stdout

def _get_absolute_paths(ctx, file_labels):
    """Return the absolut paths for the files"""

    return [ctx.path(file_label) for file_label in file_labels]

def _find_frameworks_recursively(ctx, path):
    """Return a list with all the frameworks found when searching recursively"""

    absolute_path = str(ctx.path(path))

    # Need to run an external command because recursion is not supported in bazel yet
    # See: https://github.com/bazelbuild/bazel/issues/9163
    output = _execute(ctx, "find %s -name '*.framework'" % absolute_path)
    framework_paths = [ctx.path(string) for string in output.splitlines()]
    return framework_paths

def _generate_buildfile(ctx, frameworks_parent):
    absolute_files = _get_absolute_paths(ctx, ctx.attr.file_labels)
    _copy_files(ctx, absolute_files)
    _execute(ctx, ctx.attr.cmd)

    buildfile_content = []
    frameworks = _find_frameworks_recursively(ctx, frameworks_parent)
    for framework in frameworks:
        framework_filegroup = _make_framework_filegroup(ctx, framework)
        buildfile_content.append(framework_filegroup)

    ctx.file("BUILD.bazel", "\n".join(buildfile_content))

###############
# Carthage
###############

def build_carthage_frameworks(
        name,
        carthage_version,
        git_repository_url = "https://github.com/Carthage/Carthage.git",
        directory = "",
        files = ["Cartfile"],
        cmd = """
        git clone --branch %s --depth 1 %s carthage_repo
        swift run --package-path carthage_repo carthage bootstrap --no-use-binaries --platform iOS
        """,
        timeout = timeout_default,
        verbose = verbose_default):
    """
    Builds the frameworks for the libraries specified in a Cartfile

    Args:
        name: the rule name
        carthage_version: the carthage version to use
        git_repository_url: the carthage repository to use
        directory: the path to the directory containing the carthage setup
        files: the files required for carthage to run
        cmd: the command to run and install carthage
        timeout: Timeout in seconds for prebuilding carthage frameworks
        verbose: if true, it will show the output of running carthage in the command line
    """

    # Workaround for carthage failing on Xcode 12
    # https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md
    #
    carthage_xc12_workaround = """
xcconfig=$(mktemp /tmp/static.xcconfig.XXXXXX)
trap 'rm -f "$xcconfig"' INT TERM HUP EXIT
 
# For Xcode 12 make sure EXCLUDED_ARCHS is set to arm architectures otherwise
# the build will fail on lipo due to duplicate architectures.
 
CURRENT_XCODE_VERSION="$(xcodebuild -version | grep "Xcode" | cut -d' ' -f2 | cut -d'.' -f1)00"
CURRENT_XCODE_BUILD=$(xcodebuild -version | grep "Build version" | cut -d' ' -f3)

echo "EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_${CURRENT_XCODE_VERSION}__BUILD_${CURRENT_XCODE_BUILD} = arm64 arm64e armv7 armv7s armv6 armv8" >> $xcconfig
 
echo 'EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_'${CURRENT_XCODE_VERSION}' = $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_simulator__NATIVE_ARCH_64_BIT_x86_64__XCODE_$(XCODE_VERSION_MAJOR)__BUILD_$(XCODE_PRODUCT_BUILD_VERSION))' >> $xcconfig
echo 'EXCLUDED_ARCHS = $(inherited) $(EXCLUDED_ARCHS__EFFECTIVE_PLATFORM_SUFFIX_$(EFFECTIVE_PLATFORM_SUFFIX)__NATIVE_ARCH_64_BIT_$(NATIVE_ARCH_64_BIT)__XCODE_$(XCODE_VERSION_MAJOR))' >> $xcconfig

export XCODE_XCCONFIG_FILE="$xcconfig"
"""
    _prebuilt_frameworks_importer(
        implementation = _carthage_impl,
        name = name,
        directory = directory,
        files = files,
        cmd = (carthage_xc12_workaround + cmd) % (carthage_version, git_repository_url),
        timeout = timeout,
        verbose = verbose,
    )

def _carthage_impl(ctx):
    _generate_buildfile(ctx, "Carthage/Build")

###############
# Cocoapods
###############

def build_cocoapods_frameworks(
        name,
        directory = "",
        files = ["Podfile", "Podfile.lock", "Gemfile", "Gemfile.lock"],
        cmd = """
        bundle install
        bundle exec pod install
        """,
        timeout = timeout_default,
        verbose = verbose_default):
    """
    Builds the frameworks for the pods specified in a Podfile that are using the [cocoapods-binary plugin](https://github.com/leavez/cocoapods-binary)

    Args:
        name: the rule name
        directory: the path to the directory containing the cocoapods setup
        files: the files required for cocoapods to run
        cmd: the command to install and run cocoapods
        timeout: Timeout in seconds for prebuilding cocoapods
        verbose: if true, it will show the output of running cocoapods in the command line
    """
    _prebuilt_frameworks_importer(
        implementation = _cocoapods_impl,
        name = name,
        directory = directory,
        files = files,
        cmd = cmd,
        timeout = timeout,
        verbose = verbose,
    )

def _cocoapods_impl(ctx):
    # Install all bundle infrastructure and cocoapods locally to the repository
    ctx.file(".bundle/config", "BUNDLE_PATH: 'vendor/bundle'")

    _generate_buildfile(ctx, "Pods/_Prebuild/GeneratedFrameworks")

###############
# Shared repository_rule definition
###############

def _prebuilt_frameworks_importer(
        implementation,
        name,
        directory,
        files,
        cmd,
        timeout,
        verbose):
    prebuilt_frameworks_importer = repository_rule(
        implementation = implementation,
        attrs = {
            "file_labels": attr.label_list(
                mandatory = True,
                doc = "The files from the main WORKSPACE required by the tool that will build the frameworks (cocoapods/carthage)",
            ),
            "cmd": attr.string(
                mandatory = True,
                doc = "The command for running the tool that will build the frameworks (cocoapods/carthage)",
            ),
            "timeout": attr.int(
                mandatory = False,
                default = 600,
                doc = "Execution timeout for prebuilding frameworks",
            ),
            "verbose": attr.bool(
                mandatory = True,
                doc = "Make the build verbose",
            ),
        },
        doc = "A repository rule that generates prebuilt binaries using an cocoapods or carthage",
    )

    prebuilt_frameworks_importer(
        name = name,
        file_labels = ["//" + directory + ":" + file for file in files],
        cmd = cmd,
        timeout = timeout,
        verbose = verbose,
    )
