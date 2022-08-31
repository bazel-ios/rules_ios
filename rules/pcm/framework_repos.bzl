load("@bazel_tools//tools/osx:xcode_configure.bzl", "run_xcode_locator")

def _impl(repository_ctx):
    (xcode_toolchains, _xcodeloc_err) = run_xcode_locator(
        repository_ctx,
        repository_ctx.path(Label("@bazel_tools//tools/osx:xcode_locator.m")),
    )

    repository_ctx.file("toolchains", content = json.encode(xcode_toolchains))
    repository_ctx.file("BUILD", "exports_files([\"toolchains\"])")

    for toolchain in xcode_toolchains[0:1]:
        version_name = "version{}".format(toolchain.version.replace(".", "_"))
        developer_dir_path = repository_ctx.path(toolchain.developer_dir)
        platform_dir = developer_dir_path.get_child("Platforms")
        platforms = platform_dir.readdir()
        sdk_aliases = {}
        sdk_realpaths = {}
        for platform in platforms[4:5]:
            sdk_dir = platform.get_child("Developer").get_child("SDKs")
            sdks = sdk_dir.readdir()
            for sdk in sdks:
                sdk_realpath = sdk.realpath
                sdk_aliases[sdk] = sdk_realpath
                if sdk_realpath in sdk_realpaths:
                    # Skip symlinked sdks
                    continue
                output_sdk_path = repository_ctx.path(version_name).get_child(platform.basename.replace(".platform", "")).get_child(sdk_realpath.basename.replace(".sdk", ""))

                frameworks_dir = sdk_realpath.get_child("System").get_child("Library").get_child("Frameworks")
                if not frameworks_dir.exists:
                    # Skip things like DriverKit
                    continue
                frameworks = frameworks_dir.readdir()
                all_imported_frameworks = [f.basename.replace(".framework", "") for f in frameworks if f.basename.endswith(".framework") and not f.basename.startswith("_")]

                swift_lib_dir = sdk_realpath.get_child("usr").get_child("lib").get_child("swift")
                swift_libs = swift_lib_dir.readdir()
                all_imported_frameworks.extend([s.basename.replace(".swiftmodule", "") for s in swift_libs if s.basename.endswith(".swiftmodule") and not s.basename.startswith("_")])

                import_file_content = "".join(["import {}\n".format(f) for f in all_imported_frameworks])
                imports_file = output_sdk_path.get_child("imports.swift")
                repository_ctx.file(imports_file, content = import_file_content)
                resource_dir = "{}/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift".format(developer_dir_path)
                repository_ctx.report_progress("Scanning deps for {}".format(imports_file))
                deps_result = repository_ctx.execute(
                    [
                        "swiftc",
                        "-scan-dependencies",
                        "-sdk",
                        sdk_realpath,
                        "-resource-dir",
                        resource_dir,
                        imports_file,
                    ],
                )
                if deps_result.return_code != 0:
                    fail("Could not scan dependencies for {}\n{}".format(imports_file, deps_result.stderr))
                scan_deps = json.decode(deps_result.stdout)
                repository_ctx.file(output_sdk_path.get_child("deps.json"), content = deps_result.stdout)
                build_file_lines = [
                    "load(\"@//:apple_framework_pcm.bzl\", \"apple_framework_pcm\")",
                    "load(\"@build_bazel_rules_swift//swift:swift.bzl\", \"swift_module_alias\")",
                    "",
                    "package(default_visibility = [\"//visibility:public\"])",
                    "",
                ]
                for pkg in scan_deps.get("modules", []):
                    module_name = pkg.get("modulePath", "")
                    if not module_name:
                        continue
                    clang = pkg.get("details", {}).get("clang", {})
                    if clang:
                        build_file_lines.append("apple_framework_pcm(")
                        build_file_lines.append("    name = \"{}\",".format(module_name.replace(".pcm", "")))
                        module_map_file = clang["moduleMapPath"].replace("{}/".format(developer_dir_path), "")
                        build_file_lines.append("    module_map_file = \"{}\",".format(module_map_file))
                    else:
                        build_file_lines.append("swift_module_alias(")
                        build_file_lines.append("    name = \"{}\",".format(module_name.replace(".swiftmodule", "_swift")))
                    deps = pkg.get("directDependencies", [])
                    clang_deps = [d["clang"] for d in deps if "clang" in d]
                    swift_deps = [d["swift"] for d in deps if "swift" in d]
                    if clang_deps or swift_deps:
                        build_file_lines.append("    deps = [")
                        for d in clang_deps:
                            build_file_lines.append("        \":{}\",".format(d))
                        for d in swift_deps:
                            build_file_lines.append("        \":{}_swift\",".format(d))
                        build_file_lines.append("    ],")
                    build_file_lines.append(")")
                    build_file_lines.append("")
                build_file = output_sdk_path.get_child("BUILD.bazel")
                repository_ctx.file(build_file, "\n".join(build_file_lines))

swift_sdks = repository_rule(implementation = _impl)
