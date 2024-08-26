"""Repository rule to fetch and configure SDK Clang and Swift modules for explicit module builds.

In explicit module builds, Swift targets need to depend directly on SDK Clang and Swift modules.
This repository rule is to configure the targets for SDK Clang and Swift modules.
The high-level idea is to locates all local Xcode versions, scan through all SDK frameworks, and
configure targets for them. 
"""

load("@bazel_tools//tools/osx:xcode_configure.bzl", "run_xcode_locator")

OSX_EXECUTE_TIMEOUT = 600

PLATFORM_TUPLES = [
    ("MacOSX", "macos"),
    ("iPhoneOS", "ios"),
    ("iPhoneSimulator", "ios"),
]

SDK_BUILD_FILE_TMPL = """\
load("@build_bazel_rules_ios//rules/explicit_module:sdk_clang_module.bzl", "sdk_clang_module")
load("@build_bazel_rules_ios//rules/explicit_module:sdk_swiftmodule_import.bzl", "sdk_swiftmodule_import")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_import")

package(default_visibility = ["//visibility:public"])
{sdk_targets}
"""

IMPORTS_FILE = "bazel_xcode_imports.swift"

CLANG_MODULE_TMPL = """
sdk_clang_module(
    name = "{name}_c",
    module_name = "{name}",
    module_map = "{module_map_path}",
    deps = [
{deps}
    ],
)
"""

SWIFT_MODULE_TMPL = """
sdk_swiftmodule_import(
    name = "import_swiftmodule_{name}",
    module_name = "{name}",
    swiftmodule_path = "{swiftmodule_path}",
)

swift_import(
    name = "{name}_swift",
    module_name = "{name}",
    swiftmodule = ":import_swiftmodule_{name}",
    deps = [
{deps}
    ],
)
"""

ROOT_BUILD_FILE_TMPL = """load("@bazel_skylib//lib:selects.bzl", "selects")

package(default_visibility = ["//visibility:public"])

selects.config_setting_group(
    name = "iPhoneOS",
    match_any = [
        "@build_bazel_rules_apple//apple:ios_arm64",
        "@build_bazel_rules_apple//apple:ios_arm64e",
    ],
)

selects.config_setting_group(
    name = "iPhoneSimulator",
    match_any = [
        "@build_bazel_rules_apple//apple:ios_sim_arm64",
        "@build_bazel_rules_apple//apple:ios_x86_64",
    ],
)

selects.config_setting_group(
    name = "MacOSX",
    match_any = [
        "@build_bazel_rules_apple//apple:darwin_arm64",
        "@build_bazel_rules_apple//apple:darwin_arm64e",
        "@build_bazel_rules_apple//apple:darwin_x86_64",
    ],
)
{config_setting_lines}
{xcode_sdk_framework_alias}
"""

ROOT_ALIAS_TMPL = """
alias(
    name = "{target}",
    actual = select({{
        {select_lines},
    }})
)
"""

SELECT_LINE_TMPL = '":{label}": "//{xcode_dir}:{target}"'

CONFIG_SETTING_TMPL = """
config_setting(
    name = "{label}",
    flag_values = {{
        "@bazel_tools//tools/osx:xcode_version_flag_exact": "{version}",
    }},
)
"""

XCODE_VERSION_BUILD_FILE_TMPL = """package(default_visibility = ["//visibility:public"])

# alias(
#     name = "xcode_sdk_frameworks",
#     actual = select({{
#         "//:iPhoneOS": "//{xcode_version}/iPhoneOS:bazel_xcode_imports_swift",
#         "//:iPhoneSimulator": "//{xcode_version}/iPhoneSimulator:bazel_xcode_imports_swift",
#         "//:MacOSX": "//{xcode_version}/MacOSX:bazel_xcode_imports_swift",
#         "//conditions:default": "//{xcode_version}/MacOSX:bazel_xcode_imports_swift",
#     }})
# )
"""

def _find_all_frameworks(sdk_path):
    frameworks_dir = sdk_path.get_child("System").get_child("Library").get_child("Frameworks")
    if not frameworks_dir.exists:
        # Skip things like DriverKit
        return []
    frameworks = frameworks_dir.readdir()
    return [
        f.basename.replace(".framework", "")
        for f in frameworks
        if f.basename.endswith(".framework") and not f.basename.startswith("_")
    ]

def _find_all_swift_libs(sdk_path):
    swift_lib_dir = sdk_path.get_child("usr").get_child("lib").get_child("swift")
    swift_libs = swift_lib_dir.readdir()
    return [
        s.basename.replace(".swiftmodule", "")
        for s in swift_libs
        if s.basename.endswith(".swiftmodule") and not s.basename.startswith("_")
    ]

def _scan_dependency_graph(repository_ctx, developer_dir, sdk_path, target_triple, output_folder):
    """Scans the dependencies for a library that imports every framework in a given SDK.

    Returns the JSON obtained from swiftc.
    """
    frameworks = _find_all_frameworks(sdk_path)
    frameworks.extend(_find_all_swift_libs(sdk_path))

    import_file_content = "".join(["import {}\n".format(f) for f in frameworks])
    import_file = output_folder.get_child(IMPORTS_FILE)
    repository_ctx.file(import_file, content = import_file_content)
    resource_dir = "{}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift".format(developer_dir)
    swiftc = "{}/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc".format(developer_dir)

    repository_ctx.report_progress("Scanning deps for {}".format(sdk_path))

    deps_result = repository_ctx.execute(
        [
            swiftc,
            "-scan-dependencies",
            "-sdk",
            sdk_path,
            "-resource-dir",
            resource_dir,
            "-target",
            target_triple,
            import_file,
        ],
    )
    if deps_result.return_code != 0:
        fail("Could not scan dependencies for {}\n{}".format(sdk_path, deps_result.stderr))

    repository_ctx.file(output_folder.get_child("deps.json"), deps_result.stdout)
    return json.decode(deps_result.stdout)

def _sub_bazel_path_vars(path, sdk_path, developer_dir):
    path = path.replace(str(sdk_path), "__BAZEL_XCODE_SDKROOT__")
    path = path.replace(str(developer_dir), "__BAZEL_XCODE_DEVELOPER_DIR__")
    return path

def _target_for_module(developer_dir, sdk_path, module_name_by_type, module_details, overrides):
    """Returns a string containing the BUILD target for a given framework."""

    is_swift = module_name_by_type.get("swift") != None
    module_name = module_name_by_type.get("swift") if is_swift else module_name_by_type.get("clang")
    if not module_name:
        fail("Expect module name by type, but got {}".format(module_name_by_type))
    if module_name == "bazel_xcode_imports":
        # Ignore bazel_xcode_imports
        return None

    module_deps = module_details.get("directDependencies", [])
    deps = ["{}_c".format(d["clang"]) for d in module_deps if "clang" in d]
    deps += ["{}_swift".format(d["swift"]) for d in module_deps if "swift" in d]
    if overrides and is_swift:
        deps += overrides.get(module_name, [])
    deps_string = "\n".join(sorted(["        \":{}\",".format(d) for d in deps]))

    if is_swift:
        swiftmodule_path = module_details["details"]["swift"]["compiledModuleCandidates"][0]
        return SWIFT_MODULE_TMPL.format(
            name = module_name,
            deps = deps_string,
            swiftmodule_path = swiftmodule_path,
        )

    clang_module_map_path = module_details["details"]["clang"]["moduleMapPath"]
    return CLANG_MODULE_TMPL.format(
        name = module_name,
        module_map_path = _sub_bazel_path_vars(clang_module_map_path, sdk_path, developer_dir),
        deps = deps_string,
    )

def _create_build_file_for_sdk(
        repository_ctx,
        developer_dir,
        sdk_path,
        output_folder,
        target_triple,
        overrides):
    """Creates a BUILD.bazel file connecting all the frameworks in a specified SDK."""

    scan_deps = _scan_dependency_graph(
        repository_ctx = repository_ctx,
        developer_dir = developer_dir,
        sdk_path = sdk_path,
        target_triple = target_triple,
        output_folder = output_folder,
    )

    targets = []
    modules_info = scan_deps.get("modules", [])

    # The info a module are put in 2 neighboring modules_info entries, e.g.,
    #   { "swift"/"clang" : module_name }
    #   {
    #     "modulePath": ...
    #      "directDependencies": ...
    #   }
    module_count = int(len(modules_info) / 2)
    for i in range(module_count):
        name_idx = 2 * i
        details_idx = 2 * i + 1
        target = _target_for_module(
            developer_dir = developer_dir,
            sdk_path = sdk_path,
            module_name_by_type = modules_info[name_idx],
            module_details = modules_info[details_idx],
            overrides = overrides,
        )
        if target:
            targets.append(target)

    build_file = SDK_BUILD_FILE_TMPL.format(sdk_targets = "".join(targets))
    build_file_path = output_folder.get_child("BUILD.bazel")
    repository_ctx.file(build_file_path, build_file)

def _platform_target_triple(host_cpu, platform, target_name, version):
    is_simulator = platform.endswith("Simulator")
    if host_cpu != "aarch64" and (is_simulator or platform == "MacOSX"):
        cpu = "x86_64"
    else:
        cpu = "arm64"
    return "{cpu}-apple-{platform}{version}{suffix}".format(
        cpu = cpu,
        platform = target_name,
        version = version,
        suffix = "-simulator" if is_simulator else "",
    )

def _sdk_overrides(platform, xcode_version):
    """Various hacks to work around issues with dependency scanning."""
    overrides = {}
    if xcode_version >= "14.1" and platform == "MacOSX":
        overrides["_StoreKit_SwiftUI"] = ["LocalAuthenticationEmbeddedUI_c"]
        overrides["_GroupActivities_AppKit"] = ["_CoreData_CloudKit_swift"]
    if xcode_version >= "14.0":
        overrides["GroupActivities"] = ["_CoreData_CloudKit_swift"]
    return overrides

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

def _search_sdk_version_from_output(output, sdkname):
    """Returns the SDK version given xcodebuild stdout and an sdkname."""
    return _search_string(output, "(%s" % sdkname, ")")

def _sdk_versions_by_platforms(repository_ctx, developer_dir):
    """Finds the SDK version of each platform (e.g., iOS and macOS) 

    The code is mostly copied from https://github.com/bazelbuild/bazel/blob/release-7.1.0/tools/osx/xcode_configure.bzl#L48

    Args:
        repository_ctx: the repository context.
        developer_dir: the developer fir of a given xcode version
    Returns:
        A dict from platform type to SDK version. It currently only supports iOS and macOS.
    """
    xcodebuild_result = repository_ctx.execute(
        ["xcrun", "xcodebuild", "-version", "-sdk"],
        OSX_EXECUTE_TIMEOUT,
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
        fail(error_msg)

    return {
        "ios": _search_sdk_version_from_output(xcodebuild_result.stdout, "iphoneos"),
        "macos": _search_sdk_version_from_output(xcodebuild_result.stdout, "macosx"),
    }

def _create_xcode_framework_targets(
        repository_ctx,
        xcode_version_name,
        developer_dir,
        xcode_version):
    """Creates a BUILD file for all the SDK frameworks contained in a given Xcode version."""

    developer_dir_path = repository_ctx.path(developer_dir)
    platforms_dir = developer_dir_path.get_child("Platforms")
    versions = _sdk_versions_by_platforms(repository_ctx, developer_dir)
    xcode_version_folder = repository_ctx.path(xcode_version_name)
    host_cpu = repository_ctx.os.arch
    for platform_name, target_name in PLATFORM_TUPLES:
        platform_dir = platforms_dir.get_child(platform_name + ".platform")
        platform_version = versions[target_name]

        sdk_path = platform_dir.get_child("Developer").get_child("SDKs").get_child("{}.sdk".format(platform_name))
        target_triple = _platform_target_triple(host_cpu, platform_name, target_name, platform_version)

        output_folder = xcode_version_folder.get_child(platform_name)
        overrides = _sdk_overrides(platform_name, xcode_version)
        _create_build_file_for_sdk(
            repository_ctx = repository_ctx,
            developer_dir = developer_dir_path,
            sdk_path = sdk_path,
            output_folder = output_folder,
            target_triple = target_triple,
            overrides = overrides,
        )

    xcode_version_build_file_path = xcode_version_folder.get_child("BUILD.bazel")
    repository_ctx.file(
        xcode_version_build_file_path,
        XCODE_VERSION_BUILD_FILE_TMPL,
        # XCODE_VERSION_BUILD_FILE_TMPL.format(xcode_version = xcode_version_name),
    )

def _stub_frameworks(repository_ctx):
    repository_ctx.file(
        "BUILD.bazel",
        content = """package(default_visibility = ["//visibility:public"])

objc_library(
    name = "xcode_sdk_frameworks",
)

""",
    )

def _xcode_sdk_frameworks_impl(repository_ctx):
    os_name = repository_ctx.os.name.lower()

    # Only supports on MacOS
    if not os_name.startswith("mac os x"):
        return

    use_explicit_modules = repository_ctx.os.environ.get("EXPLICIT_MODULES", False)

    if not use_explicit_modules:
        _stub_frameworks(repository_ctx)
        return

    # Locates all local xcodes
    xcode_toolchains, error = run_xcode_locator(
        repository_ctx,
        Label(repository_ctx.attr.xcode_locator),
    )
    if error:
        fail("Failed to locate xcode with error: {}".format(error))

    config_setting_lines = []
    framework_select_lines = []

    # Configures SDK frameworks for each xcode version.
    for xcode_toolchain in xcode_toolchains:
        xcode_version_name = "version{}".format(xcode_toolchain.version.replace(".", "_"))
        _create_xcode_framework_targets(
            repository_ctx = repository_ctx,
            xcode_version_name = xcode_version_name,
            developer_dir = xcode_toolchain.developer_dir,
            xcode_version = xcode_toolchain.version,
        )

        label = "xcode_{}".format(xcode_toolchain.version.replace(".", "_"))
        config_setting_lines.append(CONFIG_SETTING_TMPL.format(
            label = label,
            version = xcode_toolchain.version,
        ))

        framework_select_lines.append(SELECT_LINE_TMPL.format(
            label = label,
            xcode_dir = xcode_version_name,
            target = "xcode_sdk_frameworks",
        ))

    # root_alias = ROOT_ALIAS_TMPL.format(
    #     target = "xcode_sdk_frameworks",
    #     select_lines = ",\n        ".join(framework_select_lines),
    # )

    root_build_file = ROOT_BUILD_FILE_TMPL.format(
        config_setting_lines = "".join(config_setting_lines),
        xcode_sdk_framework_alias = "",
    )

    repository_ctx.file("BUILD.bazel", root_build_file)

xcode_sdk_frameworks = repository_rule(
    implementation = _xcode_sdk_frameworks_impl,
    environ = ["EXPLICIT_MODULES"],
    attrs = {
        "xcode_locator": attr.label(
            default = Label("@bazel_tools//tools/osx:xcode_locator.m"),
            doc = "Used to locate all local Xcode versions",
        ),
    },
)

def load_xcode_sdk_frameworks():
    xcode_sdk_frameworks(name = "xcode_sdk_frameworks")
