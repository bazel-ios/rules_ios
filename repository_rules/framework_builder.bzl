"""This file contains rules to build framework binaries from your podfile or cartfile"""

verbose_default = False  # The default verbose level when running this rules

def _create_buildfile_content(root, frameworks_subpath):
    """Creates the content of the generated build file

    Args:
        root: The root path where the BUILD.bazel file will be created
        frameworks_subpath: The path from the root where the frameworks are to be found
    """

    buildfile_content = []

    binaries_path = root
    for element in frameworks_subpath.split("/"):
        binaries_path = binaries_path.get_child(element)

    if binaries_path.exists:
        frameworks = [path for path in binaries_path.readdir() if str(path).endswith(".framework")]
        for framework in frameworks:
            new_content = """\
filegroup(
    name = "%s", 
    srcs = glob(["%s/%s/**/*"]),
    visibility = ["//visibility:public"],
)\
            """ % (framework.basename.split(".framework")[0], frameworks_subpath, framework.basename)
            buildfile_content.append(new_content)

    return buildfile_content

def _copy_files(ctx, files, destination):
    """Copy the specified files to the destination"""

    for file in files:
        _execute(ctx, "cp -r \"%s\" \"%s\"" % (file, destination))

def _execute(ctx, cmd):
    """Execute the specified command"""

    result = ctx.execute(["sh", "-c", cmd], quiet = not ctx.attr.verbose)
    if result.return_code != 0:
        fail(
            """
====== Command '%s' failed ======
====== stdout ======
%s
====== stderr ======
%s
        """ % (cmd, result.stdout, result.stderr),
        )

def _get_absolute_paths(ctx, file_labels):
    """Return the absolut paths for the files"""

    return [ctx.path(file_label) for file_label in file_labels]

###############
# Carthage
###############

def build_carthage_frameworks(
        name,
        carthage_version,
        git_repository_url = "https://github.com/Carthage/Carthage.git",
        directory = "",
        files = ["Cartfile"],
        install_cmd = "git clone --branch %s --depth 1 %s carthage_repo",
        run_cmd = "swift run --package-path carthage_repo carthage bootstrap --no-use-binaries --platform iOS",
        verbose = verbose_default):
    """Builds the frameworks for the libraries specified in a Cartfile

    Args:
        name: the rule name
        carthage_version: the carthage version to use
        git_repository_url: the carthage repository
        directory: the path to the directory containing the carthage setup
        files: the files required for carthage to succeed
        install_cmd: the command to install carthage
        run_cmd: the command to run carthage
        verbose: if true, it will show the output of running carthage in the command line
    """

    _prebuilt_frameworks_importer(
        implementation = _carthage_impl,
        name = name,
        directory = directory,
        files = files,
        install_cmd = install_cmd % (carthage_version, git_repository_url),
        run_cmd = run_cmd,
        verbose = verbose,
    )

def _carthage_impl(ctx):
    wd = ctx.path(".")

    absolut_files = _get_absolute_paths(ctx, ctx.attr.file_labels)
    _copy_files(ctx, absolut_files, wd)
    _execute(ctx, ctx.attr.install_cmd)
    _execute(ctx, ctx.attr.run_cmd)

    buildfile_content = []

    frameworks_subpath = "Carthage/Build"
    for path in ctx.path(frameworks_subpath).readdir():  # Carthage organizes the built platforms in folders
        if str(path).endswith(".version"):
            continue  # Skip version files

        dynamic_frameworks_subpath = frameworks_subpath + "/" + path.basename
        buildfile_content = buildfile_content + _create_buildfile_content(wd, dynamic_frameworks_subpath)

        static_frameworks_subpath = dynamic_frameworks_subpath + "/Static"
        buildfile_content = buildfile_content + _create_buildfile_content(wd, static_frameworks_subpath)

    ctx.file(
        "BUILD.bazel",
        "\n".join(buildfile_content),
    )

###############
# Cocoapods
###############

def build_cocoapods_frameworks(
        name,
        directory = "",
        files = ["Podfile", "Gemfile"],
        install_cmd = "bundle install",
        run_cmd = "bundle exec pod install",
        verbose = verbose_default):
    """Builds the frameworks for the pods specified in a Podfile that are using the [cocoapods-binary plugin](https://github.com/leavez/cocoapods-binary)

    Args:
        name: the rule name
        directory: the path to the directory containing the cocoapods setup
        files: the files required for cocoapods to succeed
        install_cmd: the command to install cocoapods
        run_cmd: the command to run cocoapods
        verbose: if true, it will show the output of running cocoapods in the command line
    """
    _prebuilt_frameworks_importer(
        implementation = _cocoapods_impl,
        name = name,
        directory = directory,
        files = files,
        install_cmd = install_cmd,
        run_cmd = run_cmd,
        verbose = verbose,
    )

def _cocoapods_impl(ctx):
    wd = ctx.path(".")

    # Install all bundle infrastructure and cocoapods locally to the repository
    ctx.file(".bundle/config", "BUNDLE_PATH: 'vendor/bundle'")

    absolut_files = _get_absolute_paths(ctx, ctx.attr.file_labels)
    _copy_files(ctx, absolut_files, wd)
    _execute(ctx, ctx.attr.install_cmd)
    _execute(ctx, ctx.attr.run_cmd)

    buildfile_content = []
    prebuild_subpath = "Pods/_Prebuild/GeneratedFrameworks"
    for path in ctx.path(prebuild_subpath).readdir():
        filegroups = _create_buildfile_content(wd, prebuild_subpath + "/" + path.basename)
        buildfile_content = buildfile_content + filegroups

    ctx.file(
        "BUILD.bazel",
        "\n".join(buildfile_content),
    )

###############
# Shared repository_rule definition
###############

def _prebuilt_frameworks_importer(
        implementation,
        name,
        directory,
        files,
        install_cmd,
        run_cmd,
        verbose):
    prebuilt_frameworks_importer = repository_rule(
        implementation = implementation,
        attrs = {
            "file_labels": attr.label_list(
                mandatory = True,
                doc = "The files from the main WORKSPACE required by the tool that will build the frameworks (cocoapods/carthage)",
            ),
            "install_cmd": attr.string(
                mandatory = True,
                doc = "The command for installing the tool that will build the frameworks (cocoapods/carthage)",
            ),
            "run_cmd": attr.string(
                mandatory = True,
                doc = "The command for running the tool that will build the frameworks (cocoapods/carthage)",
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
        install_cmd = install_cmd,
        run_cmd = run_cmd,
        file_labels = ["//" + directory + ":" + file for file in files],
        verbose = verbose,
    )
