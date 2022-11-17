"""Repository rule for adding explicit module dependencies via rules_swift.

Locates all local Xcode versions, scans through the frameworks in all SDKs, and makes them
accessible via `@xcode_sdk_frameworks` or similar. All swift targets will
need to depend directly on this module in order to build with explicit modules.
"""

load(":xcode_locator.bzl", "run_xcode_locator", "xcode_version_dict")

PLATFORM_TUPLES = [
    ("AppleTVOS", "tvos"),
    ("AppleTVSimulator", "tvos"),
    ("MacOSX", "macos"),
    ("WatchOS", "watchos"),
    ("WatchSimulator", "watchos"),
    ("iPhoneOS", "ios"),
    ("iPhoneSimulator", "ios"),
]

BUILD_FILE_HEADER = """load("@build_bazel_rules_swift//swift:swift.bzl", "swift_module_alias", "swift_c_module")
load("@build_bazel_rules_apple//apple:apple.bzl", "apple_dynamic_framework_import")

package(default_visibility = ["//visibility:public"])
        
"""

IMPORTS_FILE = "bazel_xcode_imports.swift"

C_MODULE_TMPL = """
swift_c_module(
    name = "{name}_c",
    module_name = "{name}",
    system_module_map = "{module_map_file}",
    deps = [
{deps}
    ],
)
"""

SWIFT_MODULE_TMPL = """
swift_module_alias(
    name = "{name}_swift",
    deps = [
{deps}
    ],
)
"""

XCTEST_LIB = """
apple_dynamic_framework_import(
    name = "XCTest",
    framework_imports = glob(["XCTest.framework/**"]),
    deps = [
        ":CoreGraphics_c",
        ":Foundation_c",
    ] + select({
        "//:MacOSX": [":AppKit_c"],
        "//conditions:default": ["UIKit_c"],
    })
)
"""

ROOT_BUILD_FILE = """load("@bazel_skylib//lib:selects.bzl", "selects")

package(default_visibility = ["//visibility:public"])

selects.config_setting_group(
    name = "iPhoneOS",
    match_any = ["@build_bazel_rules_apple//apple:ios_armv7", "@build_bazel_rules_apple//apple:ios_arm64"],
)

selects.config_setting_group(
    name = "iPhoneSimulator",
    match_any = ["@build_bazel_rules_apple//apple:ios_i386", "@build_bazel_rules_apple//apple:ios_sim_arm64", "@build_bazel_rules_apple//apple:ios_x86_64"],
)

selects.config_setting_group(
    name = "AppleTVOS",
    match_any = ["@build_bazel_rules_apple//apple:tvos_arm64"],
)

selects.config_setting_group(
    name = "AppleTVSimulator",
    match_any = ["@build_bazel_rules_apple//apple:tvos_sim_arm64", "@build_bazel_rules_apple//apple:tvos_x86_64"],
)

selects.config_setting_group(
    name = "WatchOS",
    match_any = ["@build_bazel_rules_apple//apple:watchos_arm64", "@build_bazel_rules_apple//apple:watchos_armv7k"],
)

selects.config_setting_group(
    name = "WatchSimulator",
    match_any = ["@build_bazel_rules_apple//apple:watchos_x86_64", "@build_bazel_rules_apple//apple:watchos_arm64_32", "@build_bazel_rules_apple//apple:watchos_i386"],
)

selects.config_setting_group(
    name = "MacOSX",
    match_any = ["@build_bazel_rules_apple//apple:darwin_x86_64", "@build_bazel_rules_apple//apple:darwin_arm64", "@build_bazel_rules_apple//apple:darwin_arm64e"],
)
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

alias(
    name = "xcode_sdk_frameworks",
    actual = select({{
        "//:iPhoneOS": "//{xcode_version}/iPhoneOS:bazel_xcode_imports_swift",
        "//:iPhoneSimulator": "//{xcode_version}/iPhoneSimulator:bazel_xcode_imports_swift",
        "//:MacOSX": "//{xcode_version}/MacOSX:bazel_xcode_imports_swift",
        "//:AppleTVOS": "//{xcode_version}/AppleTVOS:bazel_xcode_imports_swift",
        "//:AppleTVSimulator": "//{xcode_version}/AppleTVSimulator:bazel_xcode_imports_swift",
        "//:WatchOS": "//{xcode_version}/WatchOS:bazel_xcode_imports_swift",
        "//:WatchSimulator": "//{xcode_version}/WatchSimulator:bazel_xcode_imports_swift",
        "//conditions:default": "//{xcode_version}/MacOSX:bazel_xcode_imports_swift",
    }})
)

alias(
    name = "XCTest",
    actual = select({{
        "//:iPhoneOS": "//{xcode_version}/iPhoneOS:XCTest",
        "//:iPhoneSimulator": "//{xcode_version}/iPhoneSimulator:XCTest",
        "//:MacOSX": "//{xcode_version}/MacOSX:XCTest",
        "//:AppleTVOS": "//{xcode_version}/AppleTVOS:XCTest",
        "//:AppleTVSimulator": "//{xcode_version}/AppleTVSimulator:XCTest",
        "//:WatchOS": "//{xcode_version}/WatchOS:XCTest",
        "//:WatchSimulator": "//{xcode_version}/WatchSimulator:XCTest",
        "//conditions:default": "//{xcode_version}/MacOSX:XCTest",
    }})
)

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

def _get_dependency_graph(repository_ctx, developer_dir, sdk_path, target_triple):
    """Scans the dependencies for a library that imports every framework in a given SDK.

    Returns the JSON obtained from swiftc.
    """
    frameworks = _find_all_frameworks(sdk_path)
    swift_lib_dir = sdk_path.get_child("usr").get_child("lib").get_child("swift")
    swift_libs = swift_lib_dir.readdir()
    frameworks.extend([
        s.basename.replace(".swiftmodule", "")
        for s in swift_libs
        if s.basename.endswith(".swiftmodule") and not s.basename.startswith("_")
    ])

    import_file_content = "".join(["import {}\n".format(f) for f in frameworks])
    repository_ctx.file(IMPORTS_FILE, content = import_file_content)
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
            IMPORTS_FILE,
        ],
    )
    repository_ctx.delete(IMPORTS_FILE)
    if deps_result.return_code != 0:
        fail("Could not scan dependencies for {}\n{}".format(sdk_path, deps_result.stderr))
    return json.decode(deps_result.stdout)

def _sub_bazel_path_vars(path, sdk_path, developer_dir):
    path = path.replace(str(sdk_path), "__BAZEL_XCODE_SDKROOT__")
    path = path.replace(str(developer_dir), "__BAZEL_XCODE_DEVELOPER_DIR__")
    return path

def _rule_for_pkg(developer_dir, sdk_path, pkg, overrides):
    """Returns a string containing the BUILD target for a given framework."""
    module_path = pkg.get("modulePath", "")
    if not module_path:
        return ""
    module_name = module_path.replace(".pcm", "").replace(".swiftmodule", "")

    clang = pkg.get("details", {}).get("clang", {})

    pkg_deps = pkg.get("directDependencies", [])
    deps = ["{}_c".format(d["clang"]) for d in pkg_deps if "clang" in d]
    deps += ["{}_swift".format(d["swift"]) for d in pkg_deps if "swift" in d]
    if overrides and not clang:
        deps += overrides.get(module_name, [])
    deps_string = "\n".join(sorted(["        \":{}\",".format(d) for d in deps]))

    if clang:
        return C_MODULE_TMPL.format(
            name = module_name,
            module_map_file = _sub_bazel_path_vars(clang["moduleMapPath"], sdk_path, developer_dir),
            deps = deps_string,
        )

    return SWIFT_MODULE_TMPL.format(
        name = module_name,
        deps = deps_string,
    )

def _create_build_file_for_sdk(
        repository_ctx,
        developer_dir,
        sdk_path,
        output_folder,
        platform_name,
        target_triple,
        overrides):
    """Creates a BUILD.bazel file connecting all the frameworks in a specified SDK."""

    scan_deps = _get_dependency_graph(
        repository_ctx = repository_ctx,
        developer_dir = developer_dir,
        sdk_path = sdk_path,
        target_triple = target_triple,
    )

    repository_ctx.file(output_folder.get_child("deps.json"), json.encode(scan_deps))

    build_file = BUILD_FILE_HEADER

    for pkg in scan_deps.get("modules", []):
        build_file += _rule_for_pkg(
            developer_dir = developer_dir,
            sdk_path = sdk_path,
            pkg = pkg,
            overrides = overrides,
        )

    repository_ctx.symlink(
        "{developer_dir}/Platforms/{platform}.platform/Developer/Library/Frameworks/XCTest.framework".format(
            developer_dir = developer_dir,
            platform = platform_name,
        ),
        output_folder.get_child("XCTest.framework"),
    )
    build_file += XCTEST_LIB

    build_file_path = output_folder.get_child("BUILD.bazel")
    repository_ctx.file(build_file_path, build_file)

def _platform_target_triple(host_cpu, platform, target_name, version):
    is_simulator = platform.endswith("Simulator")
    if host_cpu != "aarch64" and (is_simulator or platform == "MacOSX"):
        cpu = "x86_64"
    elif target_name == "watchos" and not is_simulator:
        cpu = "arm64_32"
    else:
        cpu = "arm64"
    return "{cpu}-apple-{platform}{version}{suffix}".format(
        cpu = cpu,
        platform = target_name,
        version = version,
        suffix = "-simulator" if is_simulator else "",
    )

def _get_overrides(platform, xcode_version):
    """Various hacks to work around issues with dependency scanning."""
    overrides = {}
    if xcode_version >= "14.1" and platform == "MacOSX":
        overrides["_StoreKit_SwiftUI"] = ["LocalAuthenticationEmbeddedUI_c"]
        overrides["_GroupActivities_AppKit"] = ["_CoreData_CloudKit_swift"]
    if xcode_version >= "14.0":
        overrides["GroupActivities"] = ["_CoreData_CloudKit_swift"]
    return overrides

def _create_xcode_framework_targets(
        repository_ctx,
        xcode_version_name,
        developer_dir,
        xcode_version):
    """Creates a BUILD file for all the SDK frameworks contained in a given Xcode version."""
    developer_dir_path = repository_ctx.path(developer_dir)
    platforms_dir = developer_dir_path.get_child("Platforms")
    versions = xcode_version_dict(repository_ctx, developer_dir)
    xcode_version_folder = repository_ctx.path(xcode_version_name)
    host_cpu = repository_ctx.os.arch
    for platform_name, target_name in PLATFORM_TUPLES:
        platform_dir = platforms_dir.get_child(platform_name + ".platform")
        platform_version = versions[target_name]

        sdk_path = platform_dir.get_child("Developer").get_child("SDKs").get_child("{}.sdk".format(platform_name))
        target_triple = _platform_target_triple(host_cpu, platform_name, target_name, platform_version)

        output_folder = xcode_version_folder.get_child(platform_name)
        overrides = _get_overrides(platform_name, xcode_version)
        _create_build_file_for_sdk(
            repository_ctx = repository_ctx,
            developer_dir = developer_dir_path,
            sdk_path = sdk_path,
            output_folder = output_folder,
            platform_name = platform_name,
            target_triple = target_triple,
            overrides = overrides,
        )

    xcode_version_build_file_path = xcode_version_folder.get_child("BUILD.bazel")
    repository_ctx.file(
        xcode_version_build_file_path,
        XCODE_VERSION_BUILD_FILE_TMPL.format(xcode_version = xcode_version_name),
    )

def _stub_frameworks(repository_ctx):
    repository_ctx.file(
        "BUILD.bazel",
        content = """load("@build_bazel_rules_swift//swift:swift.bzl", "swift_module_alias")

package(default_visibility = ["//visibility:public"])

objc_library(
    name = "xcode_sdk_frameworks",
)

objc_library(
    name = "XCTest",
)

""",
    )

def _impl(repository_ctx):
    os_name = repository_ctx.os.name.lower()

    if not os_name.startswith("mac os"):
        return

    use_explicit_modules = repository_ctx.os.environ.get("EXPLICIT_MODULES", False)
    if not use_explicit_modules:
        _stub_frameworks(repository_ctx)
        return

    toolchains = run_xcode_locator(
        repository_ctx,
        Label(repository_ctx.attr.xcode_locator),
    )

    build_file = ROOT_BUILD_FILE
    framework_select_lines = []
    xctest_select_lines = []

    for toolchain in toolchains:
        target_name = "version{}".format(toolchain.version.replace(".", "_"))
        _create_xcode_framework_targets(
            repository_ctx = repository_ctx,
            xcode_version_name = target_name,
            developer_dir = toolchain.developer_dir,
            xcode_version = toolchain.version,
        )

        label = "xcode_{}".format(toolchain.version.replace(".", "_"))
        build_file += (CONFIG_SETTING_TMPL.format(
            label = label,
            version = toolchain.version,
        ))

        framework_select_lines.append(SELECT_LINE_TMPL.format(
            label = label,
            xcode_dir = target_name,
            target = "xcode_sdk_frameworks",
        ))
        xctest_select_lines.append(SELECT_LINE_TMPL.format(
            label = label,
            xcode_dir = target_name,
            target = "XCTest",
        ))

    build_file += (ROOT_ALIAS_TMPL.format(target = "xcode_sdk_frameworks", select_lines = ",\n        ".join(framework_select_lines)))
    build_file += (ROOT_ALIAS_TMPL.format(target = "XCTest", select_lines = ",\n        ".join(xctest_select_lines)))
    repository_ctx.file("BUILD.bazel", build_file)

xcode_sdk_frameworks = repository_rule(
    implementation = _impl,
    environ = ["EXPLICIT_MODULES"],
    attrs = {
        "xcode_locator": attr.string(),
    },
)
