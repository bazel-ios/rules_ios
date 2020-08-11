load("@build_bazel_rules_apple//apple:providers.bzl", "AppleBundleInfo")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

def _get_attr_values_for_name(deps, provider, field):
    return [
        getattr(dep[provider], field)
        for dep in deps
        if dep and provider in dep
    ]

_TargetInfo = provider()
_SrcsInfo = provider()

_PLATFORM_MAPPING = {
    "ios": "iOS",
    "macos": "macOS",
}

_ARCH_MAPPING = {
    "ios": "arm64 arm64e",
    "macos": "i386 x86_64",
}

_PRODUCT_SPECIFIER_LENGTH = len("com.apple.product-type.")

def _dir(o):
    return [
        x
        for x in dir(o)
        if x not in ("to_json", "to_proto")
    ]

def _is_current_project_file(f):
    return f.is_source and _is_current_project_path(f.path)

def _is_current_project_path(path):
    return not path.startswith("external/")

def _srcs_info_build_files(ctx):
    path = ctx.build_file_path
    if not _is_current_project_path(path):
        return []

    return [path]

def _xcodeproj_aspect_impl(target, ctx):
    providers = []

    deps = []
    deps += getattr(ctx.rule.attr, "deps", [])
    deps += getattr(ctx.rule.attr, "infoplists", [])
    deps.append(getattr(ctx.rule.attr, "entitlements", None))

    # TODO: handle apple_resource_bundle targets
    env_vars = ()
    commandline_args = ()

    # bazel_build_target_name is the argument to bazel build. Example values:
    #   Frameworks/FWName:FWName_library
    #   @some_external_repo//Frameworks/FWName:FWName_library
    # bazel_bin_subdir is the subdirectory within bazel-bin for artifacts built by this target. Example values:
    #   Frameworks/FWName
    #   external/some_external_repo/Frameworks/FWName
    bazel_build_target_name = ""
    if target.label.workspace_name != "":
        bazel_build_target_name = "@%s//" % target.label.workspace_name
    bazel_build_target_name += "%s:%s" % (target.label.package, target.label.name)
    bazel_bin_subdir = "%s/%s" % (target.label.workspace_root, target.label.package)

    if AppleBundleInfo in target:
        bundle_info = target[AppleBundleInfo]
        test_host_appname = None
        test_host_target = None
        if ctx.rule.kind == "ios_unit_test":
            # The following converts {"env_k1": "env_v1", "env_k2": "env_v2"}
            # to (("env_k1", "env_v1"), ("env_k2", "env_v2"))
            # for both "env vars" and "command line args"
            env_key_value_pairs = getattr(ctx.rule.attr, "env", {})
            env_vars = tuple(env_key_value_pairs.items())
            commandlines_args = getattr(ctx.rule.attr, "args", [])
            commandline_args = tuple(commandlines_args)

            test_host_target = getattr(ctx.rule.attr, "test_host", None)
            if test_host_target:
                test_host_appname = test_host_target[_TargetInfo].direct_targets[0].name

        info = struct(
            name = bundle_info.bundle_name,
            bundle_id = bundle_info.bundle_id,
            bundle_extension = bundle_info.bundle_extension,
            bazel_build_target_name = bazel_build_target_name,
            bazel_bin_subdir = bazel_bin_subdir,
            srcs = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "srcs")),
            non_arc_srcs = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "non_arc_srcs")),
            asset_srcs = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "asset_srcs")),
            framework_includes = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "framework_includes")),
            cc_defines = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "cc_defines")),
            swift_defines = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "swift_defines")),
            build_files = depset(_srcs_info_build_files(ctx), transitive = _get_attr_values_for_name(deps, _SrcsInfo, "build_files")),
            product_type = bundle_info.product_type[_PRODUCT_SPECIFIER_LENGTH:],
            platform_type = bundle_info.platform_type,
            minimum_os_version = bundle_info.minimum_os_version,
            test_host_appname = test_host_appname,
            env_vars = env_vars,
            commandline_args = commandline_args,
        )
        if ctx.rule.kind != "apple_framework_packaging":
            providers.append(
                _SrcsInfo(
                    srcs = info.srcs,
                    non_arc_srcs = info.non_arc_srcs,
                    asset_srcs = info.asset_srcs,
                    framework_includes = info.framework_includes,
                    cc_defines = info.cc_defines,
                    swift_defines = info.swift_defines,
                    build_files = depset(_srcs_info_build_files(ctx)),
                    direct_srcs = [],
                ),
            )
        direct_targets = [info]
        if test_host_target:
            direct_targets.extend(test_host_target[_TargetInfo].direct_targets)
        target_info = _TargetInfo(direct_targets = direct_targets, targets = depset([info], transitive = _get_attr_values_for_name(deps, _TargetInfo, "targets")))
        providers.append(target_info)
    else:
        srcs = []
        non_arc_srcs = []
        asset_srcs = []
        for attr in _dir(ctx.rule.files):
            if attr == "srcs":
                srcs += getattr(ctx.rule.files, attr, [])
            elif attr == "non_arc_srcs":
                non_arc_srcs += getattr(ctx.rule.files, attr, [])
            else:
                asset_srcs += getattr(ctx.rule.files, attr, [])
        srcs = [f for f in srcs if _is_current_project_file(f)]
        non_arc_srcs = [f for f in non_arc_srcs if _is_current_project_file(f)]
        asset_srcs = [f for f in asset_srcs if _is_current_project_file(f)]
        framework_includes = _get_attr_values_for_name(deps, _SrcsInfo, "framework_includes")
        cc_defines = _get_attr_values_for_name(deps, _SrcsInfo, "cc_defines")
        swift_defines = _get_attr_values_for_name(deps, _SrcsInfo, "swift_defines")
        if CcInfo in target:
            framework_includes.append(target[CcInfo].compilation_context.framework_includes)
            cc_defines.append(target[CcInfo].compilation_context.defines)

        if SwiftInfo in target:
            swift_defines.append(depset(target[SwiftInfo].direct_defines))
            swift_defines.append(target[SwiftInfo].transitive_defines)
        providers.append(
            _SrcsInfo(
                srcs = depset(srcs, transitive = _get_attr_values_for_name(deps, _SrcsInfo, "srcs")),
                non_arc_srcs = depset(non_arc_srcs, transitive = _get_attr_values_for_name(deps, _SrcsInfo, "non_arc_srcs")),
                asset_srcs = depset(asset_srcs, transitive = _get_attr_values_for_name(deps, _SrcsInfo, "asset_srcs")),
                framework_includes = depset([], transitive = framework_includes),
                cc_defines = depset([], transitive = cc_defines),
                build_files = depset(_srcs_info_build_files(ctx), transitive = _get_attr_values_for_name(deps, _SrcsInfo, "build_files")),
                swift_defines = depset([], transitive = swift_defines),
                direct_srcs = srcs,
            ),
        )

        infos = None
        actual = None
        if ctx.rule.kind in ("test_suite"):
            actual = getattr(ctx.rule.attr, "tests")[0]
        elif ctx.rule.kind in ("alias"):
            actual = getattr(ctx.rule.attr, "actual")

        if actual and _TargetInfo in actual:
            infos = actual[_TargetInfo].direct_targets

        targets = None
        if infos:
            targets = depset(infos, transitive = _get_attr_values_for_name(deps, _TargetInfo, "targets"))
        else:
            targets = depset(transitive = _get_attr_values_for_name(deps, _TargetInfo, "targets"))

        providers.append(
            _TargetInfo(direct_targets = infos, targets = targets),
        )

    return providers

_xcodeproj_aspect = aspect(
    implementation = _xcodeproj_aspect_impl,
    attr_aspects = ["deps", "actual", "tests", "infoplists", "entitlements", "resources", "test_host"],
)

# Borrowed from rules_swift/compiling.bzl
def _exclude_swift_incompatible_define(define):
    """A `map_each` helper that excludes a define if it is not Swift-compatible.

    This function rejects any defines that are not of the form `FOO=1` or `FOO`.
    Note that in C-family languages, the option `-DFOO` is equivalent to
    `-DFOO=1` so we must preserve both.

    Args:
        define: A string of the form `FOO` or `FOO=BAR` that represents an
        Objective-C define.

    Returns:
        The token portion of the define it is Swift-compatible, or `None`
        otherwise.
    """
    token, equal, value = define.partition("=")
    if (not equal and not value) or (equal == "=" and value == "1"):
        return token
    return None

def _xcodeproj_impl(ctx):
    xcodegen_jsonfile = ctx.actions.declare_file(
        "%s-xcodegen.json" % ctx.attr.name,
    )
    project_name = ctx.attr.project_name if ctx.attr.project_name else ctx.attr.name + ".xcodeproj"
    if "/" in project_name:
        fail("No / allowed in project_name")

    project = ctx.actions.declare_directory(project_name)
    nesting = ctx.label.package.count("/") + 1 if ctx.label.package else 0
    src_dot_dots = "/".join([".." for x in range(nesting + 3)])
    script_dot_dots = "/".join([".." for x in range(nesting)])

    proj_options = {
        "createIntermediateGroups": True,
        "defaultConfig": "Debug",
        "groupSortPosition": "none",
        "settingPresets": "none",
    }
    proj_settings_base = {
        "BAZEL_BUILD_EXEC": "$BAZEL_STUBS_DIR/build-wrapper",
        "BAZEL_OUTPUT_PROCESSOR": "$BAZEL_STUBS_DIR/output-processor.rb",
        "BAZEL_PATH": ctx.attr.bazel_path,
        "BAZEL_WORKSPACE_ROOT": "$SRCROOT/%s" % script_dot_dots,
        "BAZEL_STUBS_DIR": "$PROJECT_FILE_PATH/bazelstubs",
        "BAZEL_INSTALLERS_DIR": "$PROJECT_FILE_PATH/bazelinstallers",
        "BAZEL_INSTALLER": "$BAZEL_INSTALLERS_DIR/%s" % ctx.executable.installer.basename,
        "CC": "$BAZEL_STUBS_DIR/clang-stub",
        "CXX": "$CC",
        "CLANG_ANALYZER_EXEC": "$CC",
        "CODE_SIGNING_ALLOWED": False,
        "DEBUG_INFORMATION_FORMAT": "dwarf",
        "DONT_RUN_SWIFT_STDLIB_TOOL": True,
        "LD": "$BAZEL_STUBS_DIR/ld-stub",
        "LIBTOOL": "/usr/bin/true",
        "SWIFT_EXEC": "$BAZEL_STUBS_DIR/swiftc-stub",
        "SWIFT_OBJC_INTERFACE_HEADER_NAME": "",
        "SWIFT_VERSION": 5,
    }
    proj_settings_debug = {
        "GCC_PREPROCESSOR_DEFINITIONS": "DEBUG",
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
        "BAZEL_DEBUG_SYMBOLS_FLAG": "--compilation_mode=dbg"
    }
    proj_settings = {
        "base": proj_settings_base,
        "configs": {
            "Debug": proj_settings_debug,
        },
    }

    targets = []
    all_transitive_targets = depset(transitive = _get_attr_values_for_name(ctx.attr.deps, _TargetInfo, "targets")).to_list()
    if ctx.attr.include_transitive_targets:
        targets = all_transitive_targets
    else:
        targets = []
        for t in _get_attr_values_for_name(ctx.attr.deps, _TargetInfo, "direct_targets"):
            targets.extend(t)

    xcodeproj_targets_by_name = {}
    xcodeproj_schemes_by_name = {}

    for target_info in targets:
        target_macho_type = "staticlib" if target_info.product_type == "framework" else "$(inherited)"
        compiled_sources = [{
            "path": paths.join(src_dot_dots, s.short_path),
            "group": paths.dirname(s.short_path),
            "optional": True,
        } for s in target_info.srcs.to_list()]
        compiled_non_arc_sources = [{
            "path": paths.join(src_dot_dots, s.short_path),
            "group": paths.dirname(s.short_path),
            "optional": True,
            "compilerFlags": "-fno-objc-arc",
        } for s in target_info.non_arc_srcs.to_list()]
        asset_sources = [{
            "path": paths.join(src_dot_dots, s.short_path),
            "group": paths.dirname(s.short_path),
            "optional": True,
            "buildPhase": "none",
        } for s in target_info.asset_srcs.to_list()]
        asset_sources += [{
            "path": paths.join(src_dot_dots, p),
            "group": paths.dirname(p),
            "optional": True,
            "buildPhase": "none",
            # TODO: add source language type once https://github.com/yonaskolb/XcodeGen/issues/850 is resolved
        } for p in target_info.build_files.to_list()]
        target_settings = {
            "PRODUCT_NAME": target_info.name,
            "BAZEL_BIN_SUBDIR": target_info.bazel_bin_subdir,
            "MACH_O_TYPE": target_macho_type,
            "CLANG_ENABLE_MODULES": "YES",
            "CLANG_ENABLE_OBJC_ARC": "YES",
        }

        # Ensure Xcode will resolve references to the XCTest framework.
        framework_search_paths = ["$(PLATFORM_DIR)/Developer/Library/Frameworks"]
        for fi in target_info.framework_includes.to_list():
            if fi[0] != "/":
                fi = "$BAZEL_WORKSPACE_ROOT/%s" % fi
            framework_search_paths.append("\"%s\"" % fi)
        target_settings["FRAMEWORK_SEARCH_PATHS"] = " ".join(framework_search_paths)

        macros = ["\"%s\"" % d for d in target_info.cc_defines.to_list()]
        macros.append("$(inherited)")
        target_settings["GCC_PREPROCESSOR_DEFINITIONS"] = " ".join(macros)

        defines_without_equal_sign = ["$(inherited)"]
        for d in target_info.swift_defines.to_list():
            d = _exclude_swift_incompatible_define(d)
            if d != None:
                defines_without_equal_sign.append(d)
        target_settings["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = " ".join(
            ["\"%s\"" % d for d in defines_without_equal_sign],
        )

        if target_info.product_type == "application":
            target_settings["INFOPLIST_FILE"] = "$BAZEL_STUBS_DIR/Info-stub.plist"
            target_settings["PRODUCT_BUNDLE_IDENTIFIER"] = target_info.bundle_id

        if target_info.product_type == "bundle.unit-test":
            target_settings["SUPPORTS_MACCATALYST"] = False
        target_dependencies = []
        test_host_appname = getattr(target_info, "test_host_appname", None)
        if test_host_appname:
            target_dependencies.append({"target": test_host_appname})
            target_settings["TEST_HOST"] = "$(BUILT_PRODUCTS_DIR)/{test_host_appname}.app/{test_host_appname}".format(test_host_appname = test_host_appname)

        target_settings["VALID_ARCHS"] = _ARCH_MAPPING[target_info.platform_type]

        xcodeproj_targets_by_name[target_info.name] = {
            "sources": compiled_sources + compiled_non_arc_sources + asset_sources,
            "type": target_info.product_type,
            "platform": _PLATFORM_MAPPING[target_info.platform_type],
            "deploymentTarget": target_info.minimum_os_version,
            "settings": target_settings,
            "dependencies": target_dependencies,
            "preBuildScripts": [{
                "name": "Build with bazel",
                "script": """
set -euxo pipefail
cd $BAZEL_WORKSPACE_ROOT

export BAZEL_DIAGNOSTICS_DIR="$BUILD_DIR/../../bazel-xcode-diagnostics/"
mkdir -p $BAZEL_DIAGNOSTICS_DIR
export DATE_SUFFIX="$(date +%Y%m%d.%H%M%S%L)"
export BAZEL_BUILD_EVENT_TEXT_FILENAME="$BAZEL_DIAGNOSTICS_DIR/build-event-$DATE_SUFFIX.txt"
export BAZEL_BUILD_EXECUTION_LOG_FILENAME="$BAZEL_DIAGNOSTICS_DIR/build-execution-log-$DATE_SUFFIX.log"
env -u RUBYOPT -u RUBY_HOME -u GEM_HOME $BAZEL_BUILD_EXEC {bazel_build_target_name}
$BAZEL_INSTALLER
""".format(bazel_build_target_name = target_info.bazel_build_target_name),
            }],
        }

        scheme_action_details = {"targets": [target_info.name]}

        env_vars_dict = {}

        for (k, v) in getattr(target_info, "env_vars", ()):
            # Specific scheme can override the ones defined under env_vars here:
            if ctx.attr.scheme_existing_envvar_overrides.get(k, None):
                env_vars_dict[k] = ctx.attr.scheme_existing_envvar_overrides[k]
            else:
                env_vars_dict[k] = v
        scheme_action_details["environmentVariables"] = env_vars_dict

        commandline_args_tuple = getattr(target_info, "commandline_args", ())
        scheme_action_details["commandLineArguments"] = {}
        for arg in commandline_args_tuple:
            scheme_action_details["commandLineArguments"][arg] = True

        # See https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md#scheme
        # on structure of xcodeproj_schemes_by_name[target_info.name]
        xcodeproj_schemes_by_name[target_info.name] = {
            "build": {
                "parallelizeBuild": False,
                "buildImplicitDependencies": False,
                "targets": {
                    target_info.name: ["run", "test", "profile"],
                },
            },
            # By putting under run action, test action will just use them automatically
            "run": scheme_action_details,
        }

        # They will show as `TestableReference` under the scheme
        if target_info.product_type == "bundle.unit-test":
            xcodeproj_schemes_by_name[target_info.name]["test"] = {"targets": [target_info.name]}

    project_file_groups = [
        {"path": paths.join(src_dot_dots, f.short_path), "optional": True}
        for f in ctx.files.additional_files
        if _is_current_project_file(f)
    ]

    xcodeproj_info = struct(
        name = paths.split_extension(project_name)[0],
        options = proj_options,
        settings = proj_settings,
        targets = xcodeproj_targets_by_name,
        schemes = xcodeproj_schemes_by_name,
        fileGroups = project_file_groups,
    )

    ctx.actions.write(xcodegen_jsonfile, xcodeproj_info.to_json())
    ctx.actions.run(
        executable = ctx.executable._xcodegen,
        arguments = ["--quiet", "--no-env", "--spec", xcodegen_jsonfile.path, "--project", project.dirname],
        inputs = [xcodegen_jsonfile],
        outputs = [project],
    )
    install_script = ctx.actions.declare_file(
        "%s-install-xcodeproj.sh" % ctx.attr.name,
    )
    installer_runfile_paths = [i.short_path for i in ctx.attr.installer[DefaultInfo].default_runfiles.files.to_list()]
    ctx.actions.expand_template(
        template = ctx.file._xcodeproj_installer_template,
        output = install_script,
        substitutions = {
            "$(project_short_path)": project.short_path,
            "$(project_full_path)": project.path,
            "$(installer_runfile_short_paths)": " ".join(installer_runfile_paths),
            "$(installer_short_path)": ctx.executable.installer.short_path,
            "$(clang_stub_short_path)": ctx.executable.clang_stub.short_path,
            "$(index_import_short_path)": ctx.executable.index_import.short_path,
            "$(clang_stub_ld_path)": ctx.executable.ld_stub.short_path,
            "$(clang_stub_swiftc_path)": ctx.executable.swiftc_stub.short_path,
            "$(print_json_leaf_nodes_path)": ctx.executable.print_json_leaf_nodes.short_path,
            "$(build_wrapper_path)": ctx.executable.build_wrapper.short_path,
            "$(infoplist_stub)": ctx.file._infoplist_stub.short_path,
            "$(output_processor_path)": ctx.file.output_processor.short_path,
            "$(workspacesettings_xcsettings_short_path)": ctx.file._workspace_xcsettings.short_path,
            "$(ideworkspacechecks_plist_short_path)": ctx.file._workspace_checks.short_path,
        },
        is_executable = True,
    )

    return [
        DefaultInfo(
            executable = install_script,
            files = depset([xcodegen_jsonfile, project]),
            runfiles = ctx.runfiles(files = [xcodegen_jsonfile, project], transitive_files = depset(
                direct = ctx.files.build_wrapper +
                         ctx.files.installer +
                         ctx.files.clang_stub +
                         ctx.files.index_import +
                         ctx.files.ld_stub +
                         ctx.files.swiftc_stub +
                         ctx.files._infoplist_stub +
                         ctx.files.print_json_leaf_nodes +
                         ctx.files._workspace_xcsettings +
                         ctx.files._workspace_checks +
                         ctx.files.output_processor,
                transitive = [ctx.attr.installer[DefaultInfo].default_runfiles.files],
            )),
        ),
    ]

xcodeproj = rule(
    implementation = _xcodeproj_impl,
    attrs = {
        "deps": attr.label_list(mandatory = True, allow_empty = False, providers = [], aspects = [_xcodeproj_aspect]),
        "include_transitive_targets": attr.bool(default = False, mandatory = False),
        "project_name": attr.string(mandatory = False),
        "bazel_path": attr.string(mandatory = False, default = "bazel"),
        "scheme_existing_envvar_overrides": attr.string_dict(allow_empty = True, default = {}, mandatory = False),
        "_xcodeproj_installer_template": attr.label(executable = False, default = Label("//tools/xcodeproj_shims:xcodeproj-installer.sh"), allow_single_file = ["sh"]),
        "_infoplist_stub": attr.label(executable = False, default = Label("//rules/test_host_app:Info.plist"), allow_single_file = ["plist"]),
        "_workspace_xcsettings": attr.label(executable = False, default = Label("//tools/xcodeproj_shims:WorkspaceSettings.xcsettings"), allow_single_file = ["xcsettings"]),
        "_workspace_checks": attr.label(executable = False, default = Label("//tools/xcodeproj_shims:IDEWorkspaceChecks.plist"), allow_single_file = ["plist"]),
        "output_processor": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:output-processor.rb"), cfg = "host", allow_single_file = True),
        "_xcodegen": attr.label(executable = True, default = Label("@com_github_yonaskolb_xcodegen//:xcodegen"), cfg = "host"),
        "index_import": attr.label(executable = True, default = Label("@com_github_lyft_index_import//:index_import"), cfg = "host"),
        "clang_stub": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:clang-stub"), cfg = "host"),
        "ld_stub": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:ld-stub"), cfg = "host"),
        "swiftc_stub": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:swiftc-stub"), cfg = "host"),
        "print_json_leaf_nodes": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:print_json_leaf_nodes"), cfg = "host"),
        "installer": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:installer"), cfg = "host"),
        "build_wrapper": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:build-wrapper"), cfg = "host"),
        "additional_files": attr.label_list(allow_files = True, allow_empty = True, default = [], mandatory = False),
    },
    executable = True,
)
