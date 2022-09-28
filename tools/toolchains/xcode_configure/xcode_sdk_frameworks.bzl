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

def _build_file_header():
    return """load("@build_bazel_rules_swift//swift:swift.bzl", "swift_module_alias", "swift_c_module")

package(default_visibility = ["//visibility:public"])
        
"""

IMPORTS_FILE = "bazel_xcode_imports.swift"

def _get_dependency_graph(repository_ctx, developer_dir, sdk_path, target_triple):
    frameworks = _find_all_frameworks(sdk_path)
    swift_lib_dir = sdk_path.get_child("usr").get_child("lib").get_child("swift")
    swift_libs = swift_lib_dir.readdir()
    frameworks.extend([s.basename.replace(".swiftmodule", "") for s in swift_libs if s.basename.endswith(".swiftmodule") and not s.basename.startswith("_")])

    import_file_content = "".join(["import {}\n".format(f) for f in frameworks])
    repository_ctx.file(IMPORTS_FILE, content = import_file_content)
    resource_dir = "{}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift".format(developer_dir)

    repository_ctx.report_progress("Scanning deps for {}".format(sdk_path))
    deps_result = repository_ctx.execute(
        [
            "swiftc",
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

C_MODULE_TMPL = """swift_c_module(
    name = "{name}_c",
    module_name = "{name}",
    system_module_map = "{module_map_file}",
    deps = [
{deps}
    ],
)

"""

SWIFT_MODULE_TMPL = """swift_module_alias(
    name = "{name}_swift",
    deps = [
{deps}
    ],
)

"""

def _sub_bazel_path_vars(path, sdk_path, developer_dir):
    path = path.replace(str(sdk_path), "__BAZEL_XCODE_SDKROOT__")
    path = path.replace(str(developer_dir), "__BAZEL_XCODE_DEVELOPER_DIR__")
    return path

def _rule_for_pkg(developer_dir, sdk_path, pkg):
    module_path = pkg.get("modulePath", "")
    if not module_path or IMPORTS_FILE in module_path:
        return ""
    module_name = module_path.replace(".pcm", "").replace(".swiftmodule", "")

    pkg_deps = pkg.get("directDependencies", [])
    deps = ["{}_c".format(d["clang"]) for d in pkg_deps if "clang" in d]
    deps += ["{}_swift".format(d["swift"]) for d in pkg_deps if "swift" in d]
    deps_string = "\n".join(sorted(["        \":{}\",".format(d) for d in deps]))

    clang = pkg.get("details", {}).get("clang", {})
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

def _create_build_file_for_sdk(repository_ctx, developer_dir, sdk_path, output_folder, target_triple):
    scan_deps = _get_dependency_graph(repository_ctx, developer_dir, sdk_path, target_triple)

    build_file = _build_file_header()

    for pkg in scan_deps.get("modules", []):
        build_file += _rule_for_pkg(developer_dir, sdk_path, pkg)

    build_file_path = output_folder.get_child("BUILD.bazel")
    repository_ctx.file(build_file_path, build_file)

def _platform_target_triple(platform, target_name, version):
    return "{cpu}-apple-{platform}{version}{suffix}".format(
        cpu = "arm64_32" if target_name == "watchos" else "arm64",
        platform = target_name,
        version = version,
        suffix = "-simulator" if platform.endswith("Simulator") else "",
    )

def _create_xcode_framework_targets(repository_ctx, xcode_version_name, developer_dir):
    """Creates a BUILD file for all the SDK frameworks contained in a given Xcode version."""
    developer_dir_path = repository_ctx.path(developer_dir)
    platforms_dir = developer_dir_path.get_child("Platforms")
    versions = xcode_version_dict(repository_ctx, developer_dir)
    for platform_name, target_name in PLATFORM_TUPLES:
        platform_dir = platforms_dir.get_child(platform_name + ".platform")
        platform_version = versions[target_name]

        sdk_dir = platform_dir.get_child("Developer").get_child("SDKs").get_child("{}.sdk".format(platform_name))
        target_triple = _platform_target_triple(platform_name, target_name, platform_version)

        output_folder = repository_ctx.path(xcode_version_name).get_child(platform_name)
        _create_build_file_for_sdk(repository_ctx, developer_dir_path, sdk_dir, output_folder, target_triple)

def _impl(repository_ctx):
    os_name = repository_ctx.os.name.lower()
    repository_ctx.file("BUILD.bazel")

    if not os_name.startswith("mac os"):
        return

    toolchains = run_xcode_locator(
        repository_ctx,
        Label(repository_ctx.attr.xcode_locator),
    )

    for toolchain in toolchains:
        target_name = "version{}".format(toolchain.version.replace(".", "_"))
        _create_xcode_framework_targets(
            repository_ctx = repository_ctx,
            xcode_version_name = target_name,
            developer_dir = toolchain.developer_dir,
        )

xcode_sdk_frameworks = repository_rule(
    implementation = _impl,
    attrs = {
        "xcode_locator": attr.string(),
    },
)
