load("@build_bazel_rules_apple//apple:providers.bzl", "AppleBundleInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")

def _get_transitive(deps, provider, field):
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
    if AppleBundleInfo in target:
        bundle_info = target[AppleBundleInfo]
        srcs = []
        bazel_name = target.label.name
        info = struct(
            name = bundle_info.bundle_name,
            bundle_extension = bundle_info.bundle_extension,
            package = target.label.package,
            bazel_name = bazel_name,
            srcs = depset(srcs, transitive = _get_transitive(deps, _SrcsInfo, "srcs")),
            build_files = depset([ctx.build_file_path], transitive = _get_transitive(deps, _SrcsInfo, "build_files")),
            product_type = bundle_info.product_type[len("com.apple.product-type."):],
        )
        providers.append(
            _SrcsInfo(
                srcs = info.srcs,
                build_files = depset([ctx.build_file_path]),
                direct_srcs = srcs,
            ),
        )
        target_info = _TargetInfo(target = info, targets = depset([info], transitive = _get_transitive(deps, _TargetInfo, "targets")))
        providers.append(target_info)
    elif ctx.rule.kind == "apple_framework_packaging":
        srcs = []
        info = struct(
            name = target.label.name,
            package = target.label.package,
            bazel_name = target.label.name,
            srcs = depset(srcs, transitive = _get_transitive(deps, _SrcsInfo, "srcs")),
            build_files = depset([ctx.build_file_path], transitive = _get_transitive(deps, _SrcsInfo, "build_files")),
            product_type = "framework",
        )
        target_info = _TargetInfo(target = info, targets = depset([info], transitive = _get_transitive(deps, _TargetInfo, "targets")))
        providers.append(target_info)
    else:
        srcs = []
        for attr in _dir(ctx.rule.files):
            srcs += getattr(ctx.rule.files, attr, [])
        srcs = [f for f in srcs if not f.path.startswith("external/")]

        providers.append(
            _SrcsInfo(
                srcs = depset(srcs, transitive = _get_transitive(deps, _SrcsInfo, "srcs")),
                build_files = depset([ctx.build_file_path], transitive = _get_transitive(deps, _SrcsInfo, "build_files")),
                direct_srcs = srcs,
            ),
        )

        info = None
        actual = None
        if ctx.rule.kind in ("test_suite"):
            actual = getattr(ctx.rule.attr, "tests")[0]
        elif ctx.rule.kind in ("alias"):
            actual = getattr(ctx.rule.attr, "actual")
        if actual and _TargetInfo in actual:
            info = actual[_TargetInfo].target

        providers.append(
            _TargetInfo(target = info, targets = depset(transitive = _get_transitive(deps, _TargetInfo, "targets"))),
        )

    return providers

_xcodeproj_aspect = aspect(
    implementation = _xcodeproj_aspect_impl,
    attr_aspects = ["deps", "actual", "tests", "infoplists", "entitlements", "resources", "test_host"],
)

def _xcodeproj_impl(ctx):
    xcodegen_yaml = ctx.actions.declare_file(
        "%s-xcodegen.yaml" % ctx.attr.name,
    )
    project_name = ctx.attr.project_name if ctx.attr.project_name else ctx.attr.name + ".xcodeproj"
    if "/" in project_name:
        fail("No / allowed in project_name")
    project = ctx.actions.declare_directory(project_name)
    nesting = ctx.label.package.count("/") + 1 if ctx.label.package else 0
    src_dot_dots = "/".join([".." for x in range(nesting + 3)])
    script_dot_dots = "/".join([".." for x in range(nesting)])
    yaml = """\
name: {name}
options:
    createIntermediateGroups: true
    defaultConfig: Debug
    groupSortPosition: none
settings:
    BAZEL_EXEC_ROOT: "__BAZEL_EXEC_ROOT__"
    BAZEL_PATH: "{bazel_path}"
    BAZEL_WORKSPACE_ROOT: "$SRCROOT/{bazel_workspace_root}"
    BAZEL_STUBS_DIR: "$PROJECT_FILE_PATH/bazelstubs"
    BAZEL_INSTALLER: "$BAZEL_STUBS_DIR/{installer_path}"
    CC: "$BAZEL_STUBS_DIR/clang-stub"
    CXX: $CC
    CLANG_ANALYZER_EXEC: $CC
    CODE_SIGNING_ALLOWED: false
    DONT_RUN_SWIFT_STDLIB_TOOL: true
    LD: "$BAZEL_STUBS_DIR/ld-stub"
    LIBTOOL: /usr/bin/true
    SWIFT_EXEC: "$BAZEL_STUBS_DIR/swiftc-stub"
    SWIFT_OBJC_INTERFACE_HEADER_NAME: ""
    SWIFT_VERSION: 5
""".format(name = paths.split_extension(project_name)[0], bazel_workspace_root = script_dot_dots, bazel_path = ctx.attr.bazel_path, installer_path = ctx.executable.installer.short_path)

    targets = []
    if ctx.attr.include_transitive_targets:
        targets = depset(transitive = _get_transitive(ctx.attr.deps, _TargetInfo, "targets")).to_list()
    else:
        targets = [t for t in _get_transitive(ctx.attr.deps, _TargetInfo, "target") if t]

    if targets:
        yaml += """\
targets:
"""
        for target in targets:
            yaml += """\
    {name}:
        sources: [{sources}]
        type: {product_type}
        platform: iOS
        settings:
            PRODUCT_NAME: {name}
            BAZEL_PACKAGE: {package}
            MACH_O_TYPE: {macho_type}
        preBuildScripts:
        - name: Build with bazel
          script: |
            set -eux
            cd $BAZEL_WORKSPACE_ROOT
            $BAZEL_PATH build $BAZEL_PACKAGE:{bazel_name}
            $BAZEL_INSTALLER
""".format(
                name = target.name,
                sources = ", ".join(['{path: "%s", group: "%s", validate: false}' % (paths.join(src_dot_dots, s.short_path), paths.dirname(s.short_path)) for s in target.srcs.to_list() if s.is_source]),
                package = target.package,
                bazel_name = target.bazel_name,
                product_type = target.product_type,
                macho_type = "staticlib" if target.product_type == "framework" else "$(inherited)",
            )

        yaml += "schemes:\n"
        for target in targets:
            if target.product_type == "framework":
                continue
            yaml += """\
    {name}:
        build:
            parallelizeBuild: false
            buildImplicitDependencies: false
            targets:
                {name}: [test]
        test:
            targets:
                - {name}
""".format(name = target.name)
    ctx.actions.write(xcodegen_yaml, yaml)

    ctx.actions.run(
        executable = ctx.executable._xcodegen,
        arguments = ["--quiet", "--no-env", "--spec", xcodegen_yaml.path, "--project", project.dirname],
        inputs = depset([xcodegen_yaml], transitive = [target.srcs for target in targets]),
        outputs = [project],
    )
    install_script = ctx.actions.declare_file(
        "%s-install-xcodeproj.sh" % ctx.attr.name,
    )

    install_script_sh = """set -eu
readonly project_path="${PWD}/%s"
readonly dest="${BUILD_WORKSPACE_DIRECTORY}/%s/"
readonly tmp_dest="${TMPDIR}/%s/"

readonly stubs_dir="${dest}/bazelstubs"
mkdir -p ${stubs_dir}

readonly installer="%s"

mkdir -p $(dirname "${stubs_dir}/${installer}")
cp "${installer}" "${stubs_dir}/${installer}"
cp "%s" "${stubs_dir}/clang-stub"
cp "%s" "${stubs_dir}/ld-stub"
cp "%s" "${stubs_dir}/swiftc-stub"

rm -fr ${tmp_dest}
mkdir -p $(dirname $tmp_dest)
cp -r "${project_path}" "$tmp_dest"
chmod -R +w "${tmp_dest}"

# always trim three ../ from path, since that's "bazel-out/darwin-fastbuild/bin"
sed -i. -E -e 's|([ "])../../../|\\1|g' -e "s|__BAZEL_EXEC_ROOT__|${PWD}|g" "${tmp_dest}/project.pbxproj"
rm "${tmp_dest}/project.pbxproj."
rsync --recursive --quiet --copy-links "${tmp_dest}" "${dest}"
""" % (
        project.short_path,
        project.short_path,
        project.path,
        ctx.executable.installer.short_path,
        ctx.executable.clang_stub.short_path,
        ctx.executable.ld_stub.short_path,
        ctx.executable.swiftc_stub.short_path,
    )
    ctx.actions.write(install_script, install_script_sh, is_executable = True)

    return [
        DefaultInfo(
            executable = install_script,
            files = depset([xcodegen_yaml, project]),
            runfiles = ctx.runfiles(files = [xcodegen_yaml, project], transitive_files = depset(
                direct =
                    ctx.files.installer + ctx.files.clang_stub + ctx.files.ld_stub + ctx.files.swiftc_stub,
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
        "_xcodegen": attr.label(executable = True, default = Label("@com_github_yonaskolb_xcodegen//:xcodegen"), cfg = "host"),
        "clang_stub": attr.label(executable = True, default = Label("//tools/xcodeproj-shims:clang-stub"), cfg = "host"),
        "ld_stub": attr.label(executable = True, default = Label("//tools/xcodeproj-shims:ld-stub"), cfg = "host"),
        "swiftc_stub": attr.label(executable = True, default = Label("//tools/xcodeproj-shims:swiftc-stub"), cfg = "host"),
        "installer": attr.label(executable = True, default = Label("//tools/xcodeproj-shims:installer"), cfg = "host"),
    },
    executable = True,
)
