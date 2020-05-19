load("@build_bazel_rules_apple//apple:providers.bzl", "AppleBundleInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

def _get_attr_values_for_name(deps, provider, field):
    return [
        getattr(dep[provider], field)
        for dep in deps
        if dep and provider in dep
    ]

_TargetInfo = provider()
_SrcsInfo = provider()

def _dir(o):
    return [
        x
        for x in dir(o)
        if x not in ("to_json", "to_proto")
    ]

def _xcodeproj_aspect_impl(target, ctx):
    providers = []

    deps = []
    deps += getattr(ctx.rule.attr, "deps", [])
    deps += getattr(ctx.rule.attr, "infoplists", [])
    deps.append(getattr(ctx.rule.attr, "entitlements", None))

    # TODO: handle apple_resource_bundle targets
    test_env_vars = ()
    test_commandline_args = ()
    if AppleBundleInfo in target:
        bundle_info = target[AppleBundleInfo]
        bazel_name = target.label.name
        test_host_appname = None
        test_host_target = None
        if ctx.rule.kind == "ios_unit_test":
            env_key_value_pairs = getattr(ctx.rule.attr, "env", {})

            # This converts {"env_k1": "env_v1", "env_k2": "env_v2"}
            # to (("env_k1", "env_v1"), ("env_k2", "env_v2"))
            test_env_vars = tuple(env_key_value_pairs.items())
            commandlines_args = getattr(ctx.rule.attr, "args", [])
            test_commandline_args = tuple(commandlines_args)
            test_host_target = getattr(ctx.rule.attr, "test_host", None)

            if test_host_target and test_host_target.label.package != "rules/test_host_app":
                test_host_appname = test_host_target.label.name

        info = struct(
            name = bundle_info.bundle_name,
            bundle_id = getattr(ctx.rule.attr, "bundle_id", None),
            bundle_extension = bundle_info.bundle_extension,
            package = target.label.package,
            bazel_name = bazel_name,
            srcs = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "srcs")),
            asset_srcs = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "asset_srcs")),
            build_files = depset([ctx.build_file_path], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "build_files")),
            product_type = bundle_info.product_type[len("com.apple.product-type."):],
            test_env_vars = test_env_vars,
            test_commandline_args = test_commandline_args,
            test_host_appname = test_host_appname,
        )
        providers.append(
            _SrcsInfo(
                srcs = info.srcs,
                asset_srcs = info.asset_srcs,
                build_files = depset([ctx.build_file_path]),
                direct_srcs = [],
            ),
        )
        direct_targets = [info]
        if test_host_target:
            direct_targets.extend(test_host_target[_TargetInfo].direct_targets)
        target_info = _TargetInfo(direct_targets = direct_targets, targets = depset([info], transitive = _get_attr_values_for_name(deps, _TargetInfo, "targets")))
        providers.append(target_info)
    elif ctx.rule.kind == "apple_framework_packaging":
        info = struct(
            name = target.label.name,
            bundle_id = None,
            package = target.label.package,
            bazel_name = target.label.name,
            srcs = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "srcs")),
            asset_srcs = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "asset_srcs")),
            build_files = depset([ctx.build_file_path], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "build_files")),
            product_type = "framework",
            test_env_vars = test_env_vars,
            test_commandline_args = test_commandline_args,
        )
        target_info = _TargetInfo(direct_targets = [info], targets = depset([info], transitive = _get_attr_values_for_name(deps, _TargetInfo, "targets")))
        providers.append(target_info)
    else:
        srcs = []
        asset_srcs = []
        for attr in _dir(ctx.rule.files):
            if attr == "srcs":
                srcs += getattr(ctx.rule.files, attr, [])
            else:
                asset_srcs += getattr(ctx.rule.files, attr, [])
        srcs = [f for f in srcs if not f.path.startswith("external/") and f.is_source]
        asset_srcs = [f for f in asset_srcs if not f.path.startswith("external/") and f.is_source]

        providers.append(
            _SrcsInfo(
                srcs = depset(srcs, transitive = _get_attr_values_for_name(deps, _SrcsInfo, "srcs")),
                asset_srcs = depset(asset_srcs, transitive = _get_attr_values_for_name(deps, _SrcsInfo, "asset_srcs")),
                build_files = depset([ctx.build_file_path], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "build_files")),
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
    }
    proj_settings = {
        "BAZEL_PATH": ctx.attr.bazel_path,
        "BAZEL_WORKSPACE_ROOT": "$SRCROOT/%s" % script_dot_dots,
        "BAZEL_STUBS_DIR": "$PROJECT_FILE_PATH/bazelstubs",
        "BAZEL_INSTALLER": "$BAZEL_STUBS_DIR/%s" % ctx.executable.installer.short_path,
        "CC": "$BAZEL_STUBS_DIR/clang-stub",
        "CXX": "$CC",
        "CLANG_ANALYZER_EXEC": "$CC",
        "CODE_SIGNING_ALLOWED": False,
        "DONT_RUN_SWIFT_STDLIB_TOOL": True,
        "LD": "$BAZEL_STUBS_DIR/ld-stub",
        "LIBTOOL": "/usr/bin/true",
        "SWIFT_EXEC": "$BAZEL_STUBS_DIR/swiftc-stub",
        "SWIFT_OBJC_INTERFACE_HEADER_NAME": "",
        "SWIFT_VERSION": 5,
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
        asset_sources = [{
            "path": paths.join(src_dot_dots, s.short_path),
            "group": paths.dirname(s.short_path),
            "optional": True,
            "buildPhase": "none",
        } for s in target_info.asset_srcs.to_list()]
        target_settings = {
            "PRODUCT_NAME": target_info.name,
            "BAZEL_PACKAGE": target_info.package,
            "MACH_O_TYPE": target_macho_type,
        }
        if target_info.product_type == "application":
            target_settings["INFOPLIST_FILE"] = "$BAZEL_STUBS_DIR/Info-stub.plist"
            target_settings["PRODUCT_BUNDLE_IDENTIFIER"] = target_info.bundle_id
        target_dependencies = []
        test_host_appname = getattr(target_info, "test_host_appname", None)
        if test_host_appname:
            target_dependencies.append({"target": test_host_appname})
            target_settings["TEST_HOST"] = "$(BUILT_PRODUCTS_DIR)/{test_host_appname}.app/{test_host_appname}".format(test_host_appname = test_host_appname)

        xcodeproj_targets_by_name[target_info.name] = {
            "sources": compiled_sources + asset_sources,
            "type": target_info.product_type,
            "platform": "iOS",
            "settings": target_settings,
            "dependencies": target_dependencies,
            "preBuildScripts": [{
                "name": "Build with bazel",
                "script": """
set -eux
cd $BAZEL_WORKSPACE_ROOT

$BAZEL_PATH build $BAZEL_PACKAGE:{bazel_name}
$BAZEL_INSTALLER
""".format(bazel_name = target_info.bazel_name),
            }],
        }
        if target_info.product_type == "framework":
            continue

        scheme_action_name = "test"
        if target_info.product_type == "application":
            scheme_action_name = "run"
        scheme_action_details = {"targets": [target_info.name]}

        test_env_vars_dict = {}

        # target_info.test_env_vars looks like (("env_k1", "env_v1"), ("env_k2", "env_v2"))
        for kvPair in getattr(target_info, "test_env_vars", ()):
            k = kvPair[0]
            v = kvPair[1]
            if ctx.attr.scheme_existing_envvar_overrides.get(k, None):
                test_env_vars_dict[k] = ctx.attr.scheme_existing_envvar_overrides[k]
            else:
                test_env_vars_dict[k] = v

        scheme_action_details["environmentVariables"] = test_env_vars_dict
        test_commandline_args_tuple = getattr(target_info, "test_commandline_args", ())
        scheme_action_details["commandLineArguments"] = {}
        for arg in test_commandline_args_tuple:
            scheme_action_details["commandLineArguments"][arg] = True
        xcodeproj_schemes_by_name[target_info.name] = {
            "build": {
                "parallelizeBuild": False,
                "buildImplicitDependencies": False,
                "targets": {
                    target_info.name: [scheme_action_name],
                },
            },
            scheme_action_name: scheme_action_details,
        }

    xcodeproj_info = struct(
        name = paths.split_extension(project_name)[0],
        options = proj_options,
        settings = proj_settings,
        targets = xcodeproj_targets_by_name,
        schemes = xcodeproj_schemes_by_name,
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

    ctx.actions.expand_template(
        template = ctx.file._xcodeproj_installer_template,
        output = install_script,
        substitutions = {
            "$(project_short_path)": project.short_path,
            "$(project_full_path)": project.path,
            "$(installer_short_path)": ctx.executable.installer.short_path,
            "$(clang_stub_short_path)": ctx.executable.clang_stub.short_path,
            "$(clang_stub_ld_path)": ctx.executable.ld_stub.short_path,
            "$(clang_stub_swiftc_path)": ctx.executable.swiftc_stub.short_path,
            "$(infoplist_stub)": ctx.file._infoplist_stub.short_path,
            "$(workspacesettings_xcsettings_short_path)": ctx.file._workspace_xcsettings.short_path,
        },
        is_executable = True,
    )

    return [
        DefaultInfo(
            executable = install_script,
            files = depset([xcodegen_jsonfile, project]),
            runfiles = ctx.runfiles(files = [xcodegen_jsonfile, project], transitive_files = depset(
                direct = ctx.files.installer + ctx.files.clang_stub + ctx.files.ld_stub + ctx.files.swiftc_stub + ctx.files._infoplist_stub + ctx.files._workspace_xcsettings,
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
        "_xcodeproj_installer_template": attr.label(executable = False, default = Label("//tools/xcodeproj-shims:xcodeproj-installer.sh"), allow_single_file = ["sh"]),
        "_infoplist_stub": attr.label(executable = False, default = Label("//rules/test_host_app:Info.plist"), allow_single_file = ["plist"]),
        "_workspace_xcsettings": attr.label(executable = False, default = Label("//tools/xcodeproj-shims:WorkspaceSettings.xcsettings"), allow_single_file = ["xcsettings"]),
        "_xcodegen": attr.label(executable = True, default = Label("@com_github_yonaskolb_xcodegen//:xcodegen"), cfg = "host"),
        "clang_stub": attr.label(executable = True, default = Label("//tools/xcodeproj-shims:clang-stub"), cfg = "host"),
        "ld_stub": attr.label(executable = True, default = Label("//tools/xcodeproj-shims:ld-stub"), cfg = "host"),
        "swiftc_stub": attr.label(executable = True, default = Label("//tools/xcodeproj-shims:swiftc-stub"), cfg = "host"),
        "installer": attr.label(executable = True, default = Label("//tools/xcodeproj-shims:installer"), cfg = "host"),
    },
    executable = True,
)
