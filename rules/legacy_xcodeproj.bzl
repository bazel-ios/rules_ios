""" Legacy Xcode Project Generation Logic """

load("@build_bazel_rules_apple//apple:providers.bzl", "AppleBundleInfo")
load("@build_bazel_rules_apple//apple/internal:platform_support.bzl", "platform_support")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("//rules:hmap.bzl", "HeaderMapInfo")
load("//rules/framework:vfs_overlay.bzl", "VFSOverlayInfo", VFS_OVERLAY_FRAMEWORK_SEARCH_PATH = "FRAMEWORK_SEARCH_PATH")
load("//rules:additional_scheme_info.bzl", "AdditionalSchemeInfo")
load("//rules:features.bzl", "feature_names")

def _get_attr_values_for_name(deps, provider, field):
    return [
        getattr(dep[provider], field)
        for dep in deps
        if dep and provider in dep
    ]

_ProjectOptionsInfo = provider()
_TargetInfo = provider()
_SrcsInfo = provider()

_PLATFORM_MAPPING = {
    "ios": "iOS",
    "macos": "macOS",
}

_PRODUCT_SPECIFIER_LENGTH = len("com.apple.product-type.")

_IGNORE_AS_TARGET_TAG = "xcodeproj-ignore-as-target"

def _dir(o):
    return [
        x
        for x in dir(o)
        if x not in ("to_json", "to_proto")
    ]

def _is_current_project_file(f):
    return f.is_source and _is_current_project_path(f.path)

def _is_current_package_file(f, current_package):
    return _is_current_project_file(f) and f.owner.package == current_package

def _is_current_project_path(path):
    return not path.startswith("external/")

def _srcs_info_build_files(ctx):
    path = ctx.build_file_path
    if not _is_current_project_path(path):
        return []

    return [path]

def _xcodeproj_aspect_collect_hmap_paths(deps):
    """Helper method collecting hmap paths from HeaderMapInfo

    Args:
        deps: array of deps collected from target
        target: same as what is passed into aspect impl
        ctx: same as what is passed into aspect impl

    Returns:
        Array of hmap paths (relative to bazel root)
    """
    hmap_paths = []
    for dep in deps:
        if HeaderMapInfo in dep:
            files = getattr(dep[HeaderMapInfo], "files").to_list()
            for file in files:
                # Relative to workspace root
                relative_path = getattr(file, "path")
                hmap_paths.append(relative_path)
    return hmap_paths

def _make_swift_vfs_args(vfs_path):
    return [
        "-Xfrontend",
        "-vfsoverlay$BAZEL_WORKSPACE_ROOT/{}".format(vfs_path),
        "-Xfrontend",
        "-F{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
        "-I{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
        "-Xcc",
        "-ivfsoverlay$BAZEL_WORKSPACE_ROOT/{}".format(vfs_path),
        "-Xcc",
        "-F{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
        "-vfsoverlay$BAZEL_WORKSPACE_ROOT/{}".format(vfs_path),
        "-F{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
    ]

def _make_swift_copts(deps):
    hmap_files = []
    vfs_files = []
    collected_vfs = False
    for dep in deps:
        if VFSOverlayInfo in dep and not collected_vfs:
            vfs_files.extend(dep[VFSOverlayInfo].files.to_list())
            collected_vfs = True
        if HeaderMapInfo in dep:
            hmap_files.extend(dep[HeaderMapInfo].files.to_list())

    copts = []
    for hmap in hmap_files:
        copts.append("-Xcc")
        hmap_arg = "-I$BAZEL_WORKSPACE_ROOT/%s" % hmap.path
        copts.append("\"%s\"" % hmap_arg)

    # Include the root
    copts.append("-Xcc")
    copts.append("-I\"$BAZEL_WORKSPACE_ROOT\"")

    for vfs in vfs_files:
        copts.extend(_make_swift_vfs_args(vfs.path))
    return copts

# Put copts inside of a depset as a string
def _join_copts(copts):
    if not copts:
        return []
    return [" ".join(copts)]

# Get the swift_libaries' copts propagate the deps copts. This is needed to
# push the copts upwards from the libraries to top level bundles.
def _xcodeproj_aspect_collect_swift_copts(deps, ctx):
    copts = None
    if ctx.rule.kind == "swift_library":
        copts = _make_swift_copts(deps)
    else:
        for dep in deps:
            if _SrcsInfo in dep:
                dep_swift_opts_list = dep[_SrcsInfo].swift_copts.to_list()
                if len(dep_swift_opts_list):
                    return dep_swift_opts_list
    return _join_copts(copts)

def _make_objc_vfs_args(vfs_path):
    return [
        "-ivfsoverlay$BAZEL_WORKSPACE_ROOT/{}".format(vfs_path),
        "-F{}".format(VFS_OVERLAY_FRAMEWORK_SEARCH_PATH),
    ]

# Derives hmap copts and vfs copts from the inputs as rules_ios handles them.
# This is similar to what it does for HEADER_SEARCH_PATHS. Longer term, perhaps
# code can be removed in-favor for XCHammer.
def _make_objc_copts(deps):
    hmap_files = []
    vfs_files = []
    collected_vfs = False
    for dep in deps:
        if VFSOverlayInfo in dep and not collected_vfs:
            vfs_files.extend(dep[VFSOverlayInfo].files.to_list())
            collected_vfs = True
        if HeaderMapInfo in dep:
            hmap_files.extend(dep[HeaderMapInfo].files.to_list())

    copts = []
    for hmap in hmap_files:
        hmap_arg = "-I$BAZEL_WORKSPACE_ROOT/%s" % hmap.path
        copts.append("\"%s\"" % hmap_arg)

    # Include the root
    copts.append("-I\"$BAZEL_WORKSPACE_ROOT\"")

    for vfs in vfs_files:
        copts.extend(_make_objc_vfs_args(vfs.path))
    return copts

# Similar to above but for objc
def _xcodeproj_aspect_collect_objc_copts(deps, ctx):
    copts = None
    if ctx.rule.kind == "objc_library":
        copts = _make_objc_copts(deps)
    else:
        for dep in deps:
            if _SrcsInfo in dep:
                dep_objc_copts = dep[_SrcsInfo].objc_copts.to_list()
                if len(dep_objc_copts):
                    return dep_objc_copts
    return _join_copts(copts)

def _targeted_device_family(ctx):
    """ The targeted device family of the rule

    Args:
        ctx: same as what is passed into aspect impl
    Returns:
        the targeted device family in the format recognized by xcode
    """
    families = platform_support.ui_device_family_plist_value(platform_prerequisites = struct(
        device_families = getattr(ctx.rule.attr, "families", []),
    ))
    return ",".join(["%d" % family for family in families]) if families else None

def _xcodeproj_aspect_impl(target, ctx):
    providers = []

    deps = []
    deps += getattr(ctx.rule.attr, "deps", [])
    deps += getattr(ctx.rule.attr, "infoplists", [])
    deps += getattr(ctx.rule.attr, "extensions", [])
    tags = getattr(ctx.rule.attr, "tags", [])

    entitlements = getattr(ctx.rule.attr, "entitlements", None)
    if entitlements:
        deps.append(entitlements)

    virtualize_frameworks = feature_names.virtualize_frameworks in ctx.features
    if virtualize_frameworks:
        # Effectivly for virtual frameworks we don't need to copy the files
        # because they are read directly from the VFS
        objc_copts = _xcodeproj_aspect_collect_objc_copts(deps, ctx)
        swift_copts = _xcodeproj_aspect_collect_swift_copts(deps, ctx)
        hmap_paths = []
    else:
        objc_copts = []
        swift_copts = []
        hmap_paths = _xcodeproj_aspect_collect_hmap_paths(deps)

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
        extensions = getattr(ctx.rule.attr, "extensions", [])

        swift_objc_header_path = None
        if SwiftInfo in target:
            for h in getattr(target[apple_common.Objc], "direct_headers", []):
                if h.path.endswith("-Swift.h"):
                    swift_objc_header_path = h.path

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

        framework_includes = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "framework_includes"))
        info = struct(
            name = bundle_info.bundle_name,
            bundle_id = bundle_info.bundle_id,
            bundle_extension = bundle_info.bundle_extension,
            bazel_build_target_workspace = target.label.workspace_name or ctx.workspace_name,
            bazel_build_target_name = bazel_build_target_name,
            bazel_bin_subdir = bazel_bin_subdir,
            srcs = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "srcs")),
            non_arc_srcs = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "non_arc_srcs")),
            asset_srcs = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "asset_srcs")),
            framework_includes = framework_includes,
            cc_defines = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "cc_defines")),
            swift_defines = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "swift_defines")),
            build_files = depset(_srcs_info_build_files(ctx), transitive = _get_attr_values_for_name(deps, _SrcsInfo, "build_files")),
            product_type = bundle_info.product_type[_PRODUCT_SPECIFIER_LENGTH:],
            platform_type = bundle_info.platform_type,
            minimum_os_version = bundle_info.minimum_os_version,
            test_host_appname = test_host_appname,
            extensions = depset(extensions),
            env_vars = env_vars,
            swift_objc_header_path = swift_objc_header_path,
            swift_module_paths = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "swift_module_paths")),
            hmap_paths = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "hmap_paths")),
            swift_copts = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "swift_copts")),
            objc_copts = depset([], transitive = _get_attr_values_for_name(deps, _SrcsInfo, "objc_copts")),
            commandline_args = commandline_args,
            targeted_device_family = _targeted_device_family(ctx),
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
                    hmap_paths = info.hmap_paths,
                    swift_copts = info.swift_copts,
                    objc_copts = info.objc_copts,
                    swift_module_paths = info.swift_module_paths,
                ),
            )

        direct_targets = []
        transitive_targets = []
        if not _IGNORE_AS_TARGET_TAG in tags:
            direct_targets.append(info)
            transitive_targets.append(info)

        if test_host_target:
            test_host_direct_targets = []

            for target in test_host_target[_TargetInfo].direct_targets:
                # Add the test_host_target to the targets to be added to the xcode project
                test_host_direct_targets.extend([target])

                # Add the test_host_target's extensions to the targets to be added to the xcode project
                for extension in target.extensions.to_list():
                    test_host_direct_targets.extend(extension[_TargetInfo].direct_targets)

            direct_targets.extend(test_host_direct_targets)
            transitive_targets.extend(test_host_direct_targets)

        target_info = _TargetInfo(direct_targets = direct_targets, targets = depset(transitive_targets, transitive = _get_attr_values_for_name(deps, _TargetInfo, "targets")))
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
        asset_srcs = [f for f in asset_srcs if _is_current_package_file(f, target.label.package)]
        framework_includes = _get_attr_values_for_name(deps, _SrcsInfo, "framework_includes")
        cc_defines = _get_attr_values_for_name(deps, _SrcsInfo, "cc_defines")
        swift_defines = _get_attr_values_for_name(deps, _SrcsInfo, "swift_defines")
        if CcInfo in target:
            framework_includes.append(target[CcInfo].compilation_context.framework_includes)
            cc_defines.append(target[CcInfo].compilation_context.defines)

        swift_module_paths = []
        if SwiftInfo in target:
            swift_info = target[SwiftInfo]
            swift_defines.append(depset(_collect_swift_defines(swift_info.direct_modules)))
            swift_defines.append(depset(_collect_swift_defines(swift_info.transitive_modules.to_list())))
            swift_module_paths = [m.swift.swiftmodule.path for m in target[SwiftInfo].direct_modules]
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
                hmap_paths = depset(hmap_paths),
                swift_copts = depset(direct = swift_copts, transitive = _get_attr_values_for_name(deps, _SrcsInfo, "swift_copts")),
                objc_copts = depset(direct = objc_copts, transitive = _get_attr_values_for_name(deps, _SrcsInfo, "objc_copts")),
                swift_module_paths = depset(swift_module_paths, transitive = _get_attr_values_for_name(deps, _SrcsInfo, "swift_module_paths")),
            ),
        )

        infos = []
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
    attr_aspects = ["deps", "actual", "tests", "infoplists", "entitlements", "resources", "test_host", "extensions"],
)

def _xcodeproj_lldbinit_impl(ctx):
    # Improve this
    proj_files = ctx.attr.project[DefaultInfo].files.to_list()
    proj = proj_files[1].path

    # Gist is to dump showBuildSettings to replicate xcode runscript actions -
    # this is an impl detail
    target_cmd = "xcodebuild -showBuildSettings -project " + proj + " -scheme " + ctx.attr.target_name + " -json -sdk iphonesimulator"

    # Export Xcode build settings JSON to an env file - run this in an action,
    # the env file is not reproducible because the absolute paths. Theoretically
    # the LLDBInit should be relative, the LLDBInit is less necessary it's
    # current form with "virtual frameworks". Consider dealing with that
    cmd = """
#!/bin/bash
set -ex
# Consider moving this into an actual python script
py_script=$(mktemp /tmp/bazel-xcodeproj-intermediate.XXXXXX)
trap "rm -rf $py_script" EXIT
env_script=$(mktemp /tmp/bazel-xcodeproj-intermediate.XXXXXX)
trap "rm -rf $env_script" EXIT

cat > $py_script << "EOF"
#!/usr/bin/env python3 
import json, sys, shlex
build_settings = json.load(sys.stdin)[0]["buildSettings"]
print("/bin/bash")
print("set -e")
for bs in build_settings:
    if bs == "UID" or bs == "EXCLUDED_RECURSIVE_SEARCH_PATH_SUBDIRECTORIES" or bs == "BAZEL_LLDB_INIT_FILE" or bs == "PATH":
       continue
    parsed_cmds = shlex.split(build_settings[bs])
    cmds = " ".join(["\\\'" + x + "\\\'" for x in  parsed_cmds])
    if len(parsed_cmds) > 1:
        print("export " + bs + "=(" + cmds  + ")")
    else:
        print("export " + bs + "=" + cmds  + "")
EOF

chmod +x $py_script
""" + target_cmd + """ 2> /dev/null | $py_script > $env_script
source $env_script
cat $env_script
export BAZEL_LLDB_INIT_FILE=$PWD/""" + ctx.outputs.out.path + """
export BAZEL_WORKSPACE_ROOT=$PWD

# This isn't set for virtualize frameworks
export HEADER_SEARCH_PATHS=""
source """ + ctx.executable.runscript.path
    rs_f = ctx.actions.declare_file("rs")
    ctx.actions.write(rs_f, cmd)
    ctx.actions.run_shell(
        inputs = depset(ctx.attr.runscript[DefaultInfo].files.to_list() + [rs_f] + proj_files),
        outputs = [ctx.outputs.out],
        mnemonic = "XcodeLLDBInit",
        command = "./" + rs_f.path,
    )
    files = depset(direct = [ctx.outputs.out])
    runfiles = ctx.runfiles(files = [ctx.outputs.out])
    return [DefaultInfo(files = files, runfiles = runfiles, executable = ctx.outputs.out)]

xcodeproj_lldbinit = rule(
    implementation = _xcodeproj_lldbinit_impl,
    attrs = {
        "runscript": attr.label(mandatory = False, executable = True, cfg = "exec", default = "@build_bazel_rules_ios//tools/xcodeproj_shims:lldb-settings"),
        "project": attr.label(mandatory = True, providers = []),
        "out": attr.output(mandatory = True),
        "target_name": attr.string(),
    },
    doc = "Internal testing rule relying on assumptions about the xcodeproj rule above",
)

def _xcodeproj_project_options_impl(ctx):
    # Map of the attr name to the options value expected by XcodeGen.
    options_map = {
        "uses_tabs": "usesTabs",
        "indent_width": "indentWidth",
        "tab_width": "tabWidth",
    }

    # Accumulate all provided options into a Starlark dict.
    options = {}
    for attr, option in options_map.items():
        attr_value = getattr(ctx.attr, attr, None)
        if attr_value:
            options[option] = getattr(ctx.attr, attr)
    return [_ProjectOptionsInfo(options = options)]

xcodeproj_project_options = rule(
    implementation = _xcodeproj_project_options_impl,
    attrs = {
        "uses_tabs": attr.bool(mandatory = False),
        "indent_width": attr.int(mandatory = False),
        "tab_width": attr.int(mandatory = False),
    },
    doc = "Rule to change project options, values will fallback to Xcode default if not provided",
)

def _collect_swift_defines(modules):
    defines = {}
    for module in modules:
        swift_module = module.swift
        if swift_module and swift_module.defines:
            for x in swift_module.defines:
                defines[x] = None
    return defines.keys()

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

def _framework_search_paths_for_target(target_name, all_transitive_targets):
    # Ensure Xcode will resolve references to the XCTest framework.
    framework_search_paths = ["$(PLATFORM_DIR)/Developer/Library/Frameworks"]

    # all_transitive_targets includes all the targets built with their different configurations.
    # Some configurations are only applied when the target is reached transitively
    # (e.g. via an app or test that applies and propagates new build settings).
    for at in all_transitive_targets:
        if at.name == target_name:
            for fi in at.framework_includes.to_list():
                if fi[0] != "/":
                    fi = "$BAZEL_WORKSPACE_ROOT/%s" % fi
                framework_search_paths.append("\"%s\"" % fi)
    return framework_search_paths

def _swiftmodulepaths_for_target(target_name, all_transitive_targets):
    """Helper method to aggregate all swiftmodules paths that could be generated by this target

    Args:
        target_name: The name of the target whose header search paths we want to aggregate
        all_transitive_targets: all targets that have been traversed by the aspect

    Returns:
        One string joined by space with all swiftmodule paths, each path is quoted and separated by a space
    """
    swiftmodulefiles = []

    # all_transitive_targets includes all the targets built with their different configurations.
    # Some configurations are only applied when the target is reached transitively
    # (e.g. via an app or test that applies and propagates new build settings).
    for at in all_transitive_targets:
        if at.name == target_name:
            for modulefilename in at.swift_module_paths.to_list():
                if modulefilename not in swiftmodulefiles:
                    swiftmodulefiles.append(modulefilename)
                    swiftmodulefiles.append(modulefilename.replace(".swiftmodule", ".swiftdoc"))
                    swiftmodulefiles.append(modulefilename.replace(".swiftmodule", ".swiftsourceinfo"))

    return " ".join(swiftmodulefiles)

def _header_search_paths_for_target(target_name, all_transitive_targets):
    """Helper method transforming valid hmap paths into full absolute paths and concat together

    Args:
        target_name: The name of the target whose header search paths we want to aggregate
        all_transitive_targets: all targets that have been traversed by the aspect

    Returns:
        One string joined by absolute hmap paths, each path is quoted and separated by a space
    """
    header_search_paths = []
    all_hmaps = []

    # all_transitive_targets includes all the targets built with their different configurations.
    # Some configurations are only applied when the target is reached transitively
    # (e.g. via an app or test that applies and propagates new build settings).
    for at in all_transitive_targets:
        if at.name == target_name:
            all_hmaps.extend(at.hmap_paths.to_list())
    for hmap in all_hmaps:
        if len(hmap) == 0:
            continue
        if hmap != "." and hmap[0] != "/":
            hmap = "$BAZEL_WORKSPACE_ROOT/%s" % hmap
            header_search_paths.append("\"%s\"" % hmap)

    # We always need to include a search path at workspace root
    header_search_paths.append("\"$BAZEL_WORKSPACE_ROOT\"")
    return " ".join(header_search_paths)

def _swift_copts_for_target(target_name, all_transitive_targets):
    copts = []
    for at in all_transitive_targets:
        # Returns the first matching targets - consider finding this in another
        # routine
        if at.name == target_name:
            copts.extend(at.swift_copts.to_list())
            break
    return copts

# Similar to above but for objc
def _objc_copts_for_target(target_name, all_transitive_targets):
    copts = []
    for at in all_transitive_targets:
        if at.name == target_name:
            copts.extend(at.objc_copts.to_list())
            break
    return copts

_XCASSETS = "xcassets"
_XCDATAMODELD = "xcdatamodeld"
_XCDATAMODEL = "xcdatamodel"
_XCMAPPINGMODEL = "xcmappingmodel"
_XCSTICKERS = "xcstickers"

def _classify_asset(path):
    """Helper method to identify known extesion via the passed in path

    Args:
        path: single file/directory path (relative or absolute)

    Returns:
        A tuple where first argument is the first known extension found, or None.
        Second argument is the path that we constructed so far that leads to this known extension.
        For example: foo/bar/a.xcassets/someicon.imageset gives back
        ("xcassets", "foo/bar/a.xcassets")
    """

    # Order is important here, since we stop as soon as a match is found
    # This is especially important for xcdatamodeld vesus xcdatamodel,
    # since a xcdatamodeld can have many xcdatamodel as children
    known_xc_extensions = [_XCDATAMODELD, _XCDATAMODEL, _XCMAPPINGMODEL, _XCASSETS, _XCSTICKERS]
    path_components = path.split("/")
    path_so_far = ""
    for component in path_components:
        path_so_far += component
        for extension in known_xc_extensions:
            if component.endswith("." + extension):
                return (extension, path_so_far)

        # Match no exntesion, keep appending the component
        path_so_far += "/"

    # No match, return None and complete path
    return (None, path_so_far)

def _gather_asset_sources(target_info, path_prefix):
    """Helper method gather asset sources (non-code resources) based on its type or special names

    Args:
        target_info: containing asset_srcs and build_files that we compose the list from
        path_prefix: any prefix needed to correctly resolve a relative path in xcode proj
    Returns:
        array of dictionry, each dict represents a Target Resource described in XcodeGen:
        https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md#target-source
    """
    asset_sources = []
    datamodel_groups = {}
    catalog_groups = {}

    for s in target_info.asset_srcs.to_list():
        short_path = s.short_path
        (extension, path_so_far) = _classify_asset(short_path)

        # Reference for logics below:
        # https://github.com/bazelbuild/rules_apple/blob/master/apple/internal/partials/support/resources_support.bzl#L162
        if extension == None:
            payload = {
                "path": paths.join(path_prefix, short_path),
                "optional": True,
                "buildPhase": "none",
            }
            asset_sources.append(payload)
        elif extension in [_XCASSETS, _XCSTICKERS]:
            basename = paths.basename(path_so_far)
            if basename not in catalog_groups:
                catalog_groups[path_so_far] = basename
        elif extension in [_XCDATAMODELD, _XCDATAMODEL, _XCMAPPINGMODEL]:
            # Any file under .xcdatamodeld or .xcdatamodel is ignored but itself will be added.
            # However there two possibilities for .xcdatamodel to exist:
            # 1. foo/bar.xcdatamodel (standalone)
            # 2. foo/foo2.xcdatamodeld/bar(v2).xcdatamodel (versioned datadmodel)
            # Iteration of path components above stops at xcdatamodeld first
            # so the second case is taken care of
            datamodel_name = paths.basename(path_so_far)
            if datamodel_name not in datamodel_groups:
                datamodel_groups[path_so_far] = datamodel_name
        else:
            fail("Known extension {} returned from _classify_asset method is not handled".format(extension))

    for datamodel_key in datamodel_groups.keys():
        payload = {
            "path": paths.join(path_prefix, datamodel_key),
            "optional": True,
            "buildPhase": "none",
        }
        asset_sources.append(payload)

    for asset_key in catalog_groups.keys():
        payload = {
            "path": paths.join(path_prefix, asset_key),
            "optional": True,
            "buildPhase": "none",
        }
        asset_sources.append(payload)

    # Append BUILD.bazel files to project
    asset_sources += [{
        "path": paths.join(path_prefix, p),
        "optional": True,
        "buildPhase": "none",
        # TODO: add source language type once https://github.com/yonaskolb/XcodeGen/issues/850 is resolved
    } for p in target_info.build_files.to_list()]
    return asset_sources

_CONFLICTING_TARGET_MSG = """\
Failed to generate xcodeproj for "{}" due to conflicting targets:
Target "{}" is already defined with type "{}".
A same-name target with label "{}" of type "{}" wants to override.
Double check your rule declaration for naming or add `xcodeproj-ignore-as-target` as a tag to choose which target to ignore.
"""
_BUILD_WITH_BAZEL_SCRIPT = """
set -euxo pipefail
cd $BAZEL_WORKSPACE_ROOT

export BAZEL_DIAGNOSTICS_DIR="$BUILD_DIR/../../bazel-xcode-diagnostics/"
mkdir -p $BAZEL_DIAGNOSTICS_DIR
export DATE_SUFFIX="$(date +%Y%m%d.%H%M%S%L)"
export BAZEL_BUILD_EVENT_TEXT_FILENAME="$BAZEL_DIAGNOSTICS_DIR/build-event-$DATE_SUFFIX.txt"
export BAZEL_BUILD_EXECUTION_LOG_FILENAME="$BAZEL_DIAGNOSTICS_DIR/build-execution-log-$DATE_SUFFIX.log"
export BAZEL_PROFILE_FILENAME="$BAZEL_DIAGNOSTICS_DIR/build-profile-$DATE_SUFFIX.log"
env -u RUBYOPT -u RUBY_HOME -u GEM_HOME $BAZEL_BUILD_EXEC $BAZEL_BUILD_TARGET_LABEL
$BAZEL_INSTALLER
"""

# See https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md#scheme
# on structure of xcodeproj_schemes_by_name[target_info.name]
def _create_scheme_for_target(target_name, xcodeproj_schemes_by_name):
    if target_name in xcodeproj_schemes_by_name:
        return

    xcodeproj_schemes_by_name[target_name] = {
        "build": {
            "parallelizeBuild": False,
            "buildImplicitDependencies": False,
            "targets": {
                target_name: ["run", "test", "profile"],
            },
        },
    }

def _set_target_settings_by_config(ctx, target_settings):
    if len(ctx.attr.target_settings_by_config.keys()) == 0:
        return target_settings

    updated_target_settings = {}
    updated_target_settings["base"] = target_settings
    settings_by_config = target_settings.get("configs", {})

    for (config, settings) in ctx.attr.target_settings_by_config.items():
        if config not in settings_by_config.keys():
            settings_by_config[config] = {}

        for setting in settings:
            k = setting.rsplit("=", 1)[0]
            v = setting.rsplit("=", 1)[1]
            settings_by_config[config][k] = v

    updated_target_settings["configs"] = settings_by_config

    return updated_target_settings

def _populate_xcodeproj_targets_and_schemes(ctx, targets, src_dot_dots, all_transitive_targets):
    """Helper method to generate dicts for targets and schemes inside Xcode context

    Args:
        ctx: context provided to rule impl
        targets: each dict contains info of a bazel target (not xcode target)
        src_dot_dots: caller needs to figure out how many `../` needed to correctly points to an actual file
        all_transitive_targets: includes all the targets built with their different configurations.
        Some configurations are only applied when the target is reached transitively
        (e.g. via an app or test that applies and propagates new build settings).

    Returns:
        A tuple where first argument a dict representing xcode targets.
        Second argument represents xcode schemes
    """
    xcodeproj_targets_by_name = {}
    xcodeproj_schemes_by_name = {}

    for target_info in targets:
        target_name = target_info.name
        product_type = target_info.product_type
        lldbinit_file = "$CONFIGURATION_TEMP_DIR/%s.lldbinit" % target_name

        if target_name in xcodeproj_targets_by_name:
            existing_type = xcodeproj_targets_by_name[target_name]["type"]
            if product_type != existing_type:
                fail(_CONFLICTING_TARGET_MSG.format(ctx.label, target_name, existing_type, target_info.bazel_build_target_name, target_info.product_type))

        target_macho_type = "staticlib" if product_type == "framework.static" else "$(inherited)"
        compiled_sources = [{
            "path": paths.join(src_dot_dots, s.short_path),
            "optional": True,
        } for s in target_info.srcs.to_list()]
        compiled_non_arc_sources = [{
            "path": paths.join(src_dot_dots, s.short_path),
            "optional": True,
            "compilerFlags": "-fno-objc-arc",
        } for s in target_info.non_arc_srcs.to_list()]

        asset_sources = _gather_asset_sources(target_info, src_dot_dots)

        target_settings = {
            "PRODUCT_NAME": target_name,
            "ONLY_ACTIVE_ARCH": "YES",
            "BAZEL_BIN_SUBDIR": target_info.bazel_bin_subdir,
            "MACH_O_TYPE": target_macho_type,
            "CLANG_ENABLE_MODULES": "YES",
            "CLANG_ENABLE_OBJC_ARC": "YES",
            "BAZEL_BUILD_TARGET_LABEL": target_info.bazel_build_target_name,
            "BAZEL_BUILD_TARGET_WORKSPACE": target_info.bazel_build_target_workspace,
        }

        virtualize_frameworks = feature_names.virtualize_frameworks in ctx.features
        if virtualize_frameworks:
            target_settings["OTHER_SWIFT_FLAGS"] = _swift_copts_for_target(target_name, all_transitive_targets)
            target_settings["OTHER_CFLAGS"] = _objc_copts_for_target(target_name, all_transitive_targets)
        else:
            target_settings["BAZEL_SWIFTMODULEFILES_TO_COPY"] = _swiftmodulepaths_for_target(target_name, all_transitive_targets)
            target_settings["HEADER_SEARCH_PATHS"] = _header_search_paths_for_target(target_name, all_transitive_targets)

        framework_search_paths = _framework_search_paths_for_target(target_name, all_transitive_targets)
        target_settings["FRAMEWORK_SEARCH_PATHS"] = " ".join(framework_search_paths)

        macros = ["\"%s\"" % d for d in target_info.cc_defines.to_list()]
        macros.append("$(inherited)")
        target_settings["GCC_PREPROCESSOR_DEFINITIONS"] = " ".join(macros)

        if target_info.swift_objc_header_path:
            target_settings["SWIFT_OBJC_INTERFACE_HEADER_NAME"] = paths.basename(target_info.swift_objc_header_path)

        defines_without_equal_sign = ["$(inherited)"]
        for d in target_info.swift_defines.to_list():
            d = _exclude_swift_incompatible_define(d)
            if d != None:
                defines_without_equal_sign.append(d)
        target_settings["SWIFT_ACTIVE_COMPILATION_CONDITIONS"] = " ".join(
            ["\"%s\"" % d for d in defines_without_equal_sign],
        )
        extra_clang_flags = ["-D\'%s\'" % d for d in target_info.cc_defines.to_list()]

        if virtualize_frameworks:
            extra_clang_flags += ["-Xcc %s" % d for d in _objc_copts_for_target(target_name, all_transitive_targets)]

        target_settings["BAZEL_LLDB_SWIFT_EXTRA_CLANG_FLAGS"] = " ".join(extra_clang_flags)

        target_settings["BAZEL_LLDB_INIT_FILE"] = lldbinit_file

        if product_type == "application" or product_type == "app-extension":
            # Prevent XcodeGen from inferring a plist path on its own from target source files.
            # See PRs #593 and #601 for more context.
            target_settings["INFOPLIST_FILE"] = ""
            target_settings["PRODUCT_BUNDLE_IDENTIFIER"] = target_info.bundle_id

        if product_type == "bundle.unit-test":
            target_settings["SUPPORTS_MACCATALYST"] = False
        target_dependencies = []
        test_host_appname = getattr(target_info, "test_host_appname", None)
        if test_host_appname:
            target_dependencies.append({"target": test_host_appname})
            target_settings["TEST_HOST"] = "$(BUILT_PRODUCTS_DIR)/{test_host_appname}.app/{test_host_appname}".format(test_host_appname = test_host_appname)

        if target_info.targeted_device_family:
            target_settings["TARGETED_DEVICE_FAMILY"] = target_info.targeted_device_family

        pre_build_scripts = []

        if virtualize_frameworks:
            pre_build_scripts.append({
                "name": "Xcode 14 indexing workaround",
                "script": """
# Xcode 14 workaround to make the indexing invocations pass
if [ -n "$INDEX_DATA_STORE_DIR" ]; then
    rm -fr $INDEX_DATA_STORE_DIR/../Build/Products/**/*.framework || true
fi
            """,
            })

        if len(ctx.attr.additional_prebuild_script) > 0:
            pre_build_scripts.append({
                "name": "Additional prebuild script",
                "script": ctx.attr.additional_prebuild_script,
            })

        pre_build_scripts.append({
            "name": "Build with bazel",
            "script": _BUILD_WITH_BAZEL_SCRIPT,
        })

        target_settings = _set_target_settings_by_config(ctx, target_settings)

        xcodeproj_targets_by_name[target_name] = {
            "sources": compiled_sources + compiled_non_arc_sources + asset_sources,
            "type": product_type,
            "platform": _PLATFORM_MAPPING[target_info.platform_type],
            "deploymentTarget": target_info.minimum_os_version,
            "settings": target_settings,
            "dependencies": target_dependencies,
            "preBuildScripts": pre_build_scripts,
        }

        # Skip a scheme generation if allowlist is not empty
        # and current product type not in the list
        allow_scheme_list = ctx.attr.generate_schemes_for_product_types
        if len(allow_scheme_list) > 0 and product_type not in allow_scheme_list:
            continue

        scheme_action_details = {"targets": [target_name]}
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

        # From https://developer.apple.com/documentation/xcode-release-notes/xcode-12-release-notes
        #
        # You can now specify a path for the LLDB init file to use in a Run and Test action.
        # Configure this path in the Info tab of a scheme’s Run or Test action.
        # The path can contain a build settings macro such as ${SRCROOT}, so the file can be part of a project. (38677796) (FB5425738)
        scheme_action_details["customLLDBInit"] = lldbinit_file
        scheme_action_details["disableMainThreadChecker"] = ctx.attr.disable_main_thread_checker

        _create_scheme_for_target(target_name, xcodeproj_schemes_by_name)

        # By putting under run action, test action will just use them automatically
        xcodeproj_schemes_by_name[target_name]["run"] = scheme_action_details

        if target_info.extensions:
            for extension in target_info.extensions.to_list():
                extension_name = extension[AppleBundleInfo].bundle_name
                _create_scheme_for_target(extension_name, xcodeproj_schemes_by_name)
                xcodeproj_schemes_by_name[extension_name]["build"]["targets"][target_name] = ["run", "test", "profile"]

        scheme_infos = [target[AdditionalSchemeInfo] for target in ctx.attr.additional_scheme_infos]
        build_target_to_scheme_info = {scheme_info.build_target: scheme_info for scheme_info in scheme_infos}

        # They will show as `TestableReference` under the scheme
        if target_info.product_type == "bundle.unit-test":
            # All test targets will by default have a test action for themselves.
            xcodeproj_schemes_by_name[target_name]["test"] = {
                "targets": [target_name],
                "customLLDBInit": lldbinit_file,
                "disableMainThreadChecker": ctx.attr.disable_main_thread_checker,
            }

        elif target_name in build_target_to_scheme_info:
            # Add additional scheme information provided by any provided scheme infos.
            scheme_info_for_target = build_target_to_scheme_info[target_name]
            xcodeproj_schemes_by_name[target_name]["test"] = {
                "targets": scheme_info_for_target.test_action_targets,
                "customLLDBInit": lldbinit_file,
                "environmentVariables": [
                    {
                        "variable": env_var_name,
                        "value": env_var_value,
                        "isEnabled": True,
                    }
                    for target in scheme_info_for_target.test_action_targets
                    for env_var_name, env_var_value in target.environment_variables.items()
                ],
            }

        pre_actions_attr = ctx.attr.additional_pre_actions
        _add_pre_post_actions(target_name, xcodeproj_schemes_by_name[target_name], "preActions", pre_actions_attr, ctx.attr.provide_build_settings_from_target_for_pre_post_actions)
        post_actions_attr = ctx.attr.additional_post_actions
        _add_pre_post_actions(target_name, xcodeproj_schemes_by_name[target_name], "postActions", post_actions_attr, ctx.attr.provide_build_settings_from_target_for_pre_post_actions)
    return (xcodeproj_targets_by_name, xcodeproj_schemes_by_name)

def _add_pre_post_actions(target_name, scheme, key, actions, provide_build_settings_from_target):
    """Helper method to populate passed in scheme with pre/post actions. Note their output won't show up in build log.

    Args:
        target_name: Target the scheme is aiming at
        scheme: target scheme to update for
        key: one of preActions or postActions
        actions: original attribute passed in from ctx.attr.additional_pre_actions or ctx.attr.additional_post_actions
        provide_build_settings_from_target: whether settings of target will be available as environment variables in actions
    """
    supported_keys = ["preActions", "postActions"]
    if key not in supported_keys:
        fail("Key must be one of %s" % supported_keys)

    for action_type in actions:
        if action_type not in scheme:
            break
        actions_to_add = actions[action_type]
        payload = scheme[action_type]
        list = []

        # Note `settingsTarget` is explicitly omitted because
        # for a target with lots of env vars we might exceed Xcode arg_max limit
        for action in actions_to_add:
            action_spec = {
                "script": action,
            }
            if provide_build_settings_from_target:
                action_spec["settingsTarget"] = target_name
            list.append(action_spec)
        payload[key] = list

def _validate_output_path(output_path):
    output_path_components = output_path.split("/")
    prohibited_components = [".", ".."]
    contains_dot_paths = any([elem in output_path_components for elem in prohibited_components])
    if contains_dot_paths:
        fail("The output_path provided cant contain the following path components: <%s>" % prohibited_components)

def _xcodeproj_impl(ctx):
    _validate_output_path(ctx.attr.output_path)

    xcodegen_jsonfile = ctx.actions.declare_file(
        paths.join(ctx.attr.output_path, "%s-xcodegen.json" % ctx.attr.name),
    )
    project_name = (ctx.attr.project_name or ctx.attr.name) + ".xcodeproj"
    if "/" in project_name:
        fail("No / allowed in project_name")

    project = ctx.actions.declare_directory(paths.join(ctx.attr.output_path, project_name))
    destination_path = paths.normalize(paths.join(ctx.label.package, ctx.attr.output_path))
    nesting = destination_path.count("/") + 1 if destination_path != "." else 0
    src_dot_dots = "/".join([".."] * (nesting + 3))
    script_dot_dots = "/".join([".."] * nesting)

    proj_options = {
        "createIntermediateGroups": True,
        "defaultConfig": "Debug",
        "groupSortPosition": "none",
        "settingPresets": "none",
    }
    if ctx.attr.project_options_overrides:
        proj_options.update(ctx.attr.project_options_overrides[_ProjectOptionsInfo].options)

    proj_settings_base = {}

    # User defined macro for Bazel only
    proj_settings_base.update({
        "BAZEL_BUILD_EXEC": "$BAZEL_STUBS_DIR/build-wrapper",
        "BAZEL_OUTPUT_PROCESSOR": "$BAZEL_STUBS_DIR/output-processor.rb",
        "BAZEL_PATH": ctx.attr.bazel_path,
        "BAZEL_WORKSPACE_ROOT": "$SRCROOT/%s" % script_dot_dots,
        "BAZEL_STUBS_DIR": "$PROJECT_FILE_PATH/bazelstubs",
        "BAZEL_INSTALLERS_DIR": "$PROJECT_FILE_PATH/bazelinstallers",
        "BAZEL_INSTALLER": "$BAZEL_INSTALLERS_DIR/%s" % ctx.executable.installer.basename,
        "BAZEL_EXECUTION_LOG_ENABLED": ctx.attr.bazel_execution_log_enabled,
        "BAZEL_PROFILE_ENABLED": ctx.attr.bazel_profile_enabled,
        "BAZEL_CONFIGS": ctx.attr.configs.keys(),
        "BAZEL_ADDITIONAL_BAZEL_BUILD_OPTIONS": " ".join(["{} ".format(opt) for opt in ctx.attr.additional_bazel_build_options]),
        "BAZEL_ADDITIONAL_LLDB_SETTINGS": "\n".join(ctx.attr.additional_lldb_settings),
        "INDEX_DATA_STORE_DIR": "$(INDEX_DATA_STORE_DIR)",
    })

    # Stubbing compiler, linker executables used by xcode so no actual building happening on Xcode side
    proj_settings_base.update({
        "CC": "$BAZEL_STUBS_DIR/clang-stub",
        "CXX": "$CC",
        "CLANG_ANALYZER_EXEC": "$CC",
        "LD": "$BAZEL_STUBS_DIR/ld-stub",
        "LIBTOOL": "$BAZEL_STUBS_DIR/ld-stub",
        "SWIFT_USE_INTEGRATED_DRIVER": "NO",
        "SWIFT_EXEC": "$BAZEL_STUBS_DIR/swiftc-stub",
        # LD isn't used for all use cases - direct it to use this LD
        "OTHER_LDFLAGS": "-fuse-ld=$BAZEL_STUBS_DIR/ld-stub",
    })

    # Change of settings to help params used for compiling individual files to match closer to Bazel
    proj_settings_base.update({
        "USE_HEADERMAP": False,
    })

    # Other misc. settings changes
    proj_settings_base.update({
        "CODE_SIGNING_ALLOWED": False,
        "DEBUG_INFORMATION_FORMAT": "dwarf",
        "DONT_RUN_SWIFT_STDLIB_TOOL": True,
        "SWIFT_OBJC_INTERFACE_HEADER_NAME": "",
        "SWIFT_VERSION": 5,
        "FORCE_X86_SIM": ctx.attr.force_x86_sim,
    })

    # For debugging config only:
    proj_settings_debug = {
        "GCC_PREPROCESSOR_DEFINITIONS": "DEBUG",
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
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

    (xcodeproj_targets_by_name, xcodeproj_schemes_by_name) = _populate_xcodeproj_targets_and_schemes(ctx, targets, src_dot_dots, all_transitive_targets)

    project_file_groups = [
        paths.join(src_dot_dots, f.short_path)
        for f in ctx.files.additional_files
        if _is_current_project_file(f)
    ]

    # The 'xcodegen' tool requires at least one build configuration
    # of each type 'debug' and 'release'. Add those and set all the others to 'none'
    #
    # Note that the consumer can still set 'Debug' and 'Release' in 'ctx.attr.configs'
    # and take advantage of the configs in the .bazelrc file.
    xcodeproj_info_configs = {k: "none" for k in ctx.attr.configs.keys()}
    xcodeproj_info_configs["Debug"] = "debug"
    xcodeproj_info_configs["Release"] = "release"
    for (config, build_type) in ctx.attr.configs.items():
        xcodeproj_info_configs[config] = build_type

    xcodeproj_info = struct(
        name = paths.split_extension(project_name)[0],
        attributes = ctx.attr.project_attributes_overrides,
        options = proj_options,
        settings = proj_settings,
        configs = xcodeproj_info_configs,
        targets = xcodeproj_targets_by_name,
        schemes = xcodeproj_schemes_by_name,
        fileGroups = project_file_groups,
    )

    ctx.actions.write(xcodegen_jsonfile, xcodeproj_info.to_json())
    ctx.actions.run(
        executable = ctx.executable._xcodegen,
        arguments = ["--quiet", "--no-env", "--spec", xcodegen_jsonfile.path, "--project", project.dirname],
        inputs = [xcodegen_jsonfile] + ctx.files.additional_files,
        outputs = [project],
    )
    install_script = ctx.actions.declare_file(
        "%s-install-xcodeproj.sh" % ctx.attr.name,
    )
    installer_runfile_paths = [i.short_path for i in ctx.attr.installer[DefaultInfo].default_runfiles.files.to_list()]
    build_wrapper_runfile_paths = [i.short_path for i in ctx.attr.build_wrapper[DefaultInfo].default_runfiles.files.to_list()]
    index_import_runfiles_paths = [i.short_path for i in ctx.attr.index_import[DefaultInfo].default_runfiles.files.to_list()]

    # In order to be runnable, the print_json_leaf_nodes script needs to live
    # next to a print_json_leaf_nodes.runfiles directory that contains its runfiles.
    # The print_json_leaf_nodes_runfiles array will be populated with the subdirectories
    # and paths that the py_binary expects the runfiles directory to contain.
    print_json_leaf_nodes_runfiles = []
    for pi in ctx.attr.print_json_leaf_nodes[DefaultInfo].default_runfiles.files.to_list():
        if pi.short_path.startswith("../"):
            runfiles_subdirectory_path = pi.short_path[3:]
            print_json_leaf_nodes_runfiles.append(runfiles_subdirectory_path)
        else:
            runfiles_subdirectory_path = "%s/%s" % (ctx.workspace_name, pi.short_path)
            print_json_leaf_nodes_runfiles.append(runfiles_subdirectory_path)

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
            "$(index_import_runfiles_paths)": " ".join(index_import_runfiles_paths),
            "$(clang_stub_ld_path)": ctx.executable.ld_stub.short_path,
            "$(clang_stub_swiftc_path)": ctx.executable.swiftc_stub.short_path,
            "$(print_json_leaf_nodes_path)": ctx.executable.print_json_leaf_nodes.short_path,
            "$(print_json_leaf_nodes_runfiles)": " ".join(print_json_leaf_nodes_runfiles),
            "$(build_wrapper_path)": ctx.executable.build_wrapper.short_path,
            "$(build_wrapper_runfile_short_paths)": " ".join(build_wrapper_runfile_paths),
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
                         ctx.files.print_json_leaf_nodes +
                         ctx.files._workspace_xcsettings +
                         ctx.files._workspace_checks +
                         ctx.files.output_processor,
                transitive = [
                    ctx.attr.build_wrapper[DefaultInfo].default_runfiles.files,
                    ctx.attr.index_import[DefaultInfo].default_runfiles.files,
                    ctx.attr.installer[DefaultInfo].default_runfiles.files,
                    ctx.attr.print_json_leaf_nodes[DefaultInfo].default_runfiles.files,
                ],
            )),
        ),
    ]

xcodeproj = rule(
    implementation = _xcodeproj_impl,
    doc = """\
Generates a Xcode project file (.xcodeproj) with a reasonable set of defaults.
Tags for configuration:
    xcodeproj-ignore-as-target: Add this to a rule declaration so that this rule will not generates a scheme for this target
""",
    attrs = {
        # Important! The `Debug` is being used to conditionally pass
        # flags to LLDB, so if this behaviour ever changes that needs
        # to be considered otherwise debugging swift files will stop working
        #
        # See the logic around setting the `-D DEBUG` flag in
        # https://github.com/bazel-ios/rules_ios/blob/master/tools/xcodeproj_shims/installers/lldb-settings.sh
        "configs": attr.string_dict(mandatory = False, default = {}, doc = """
        Dictionary keyed at config name present in the .bazelrc file and values at one of these two config types: 'debug', 'release'

        A Xcode build configuration will be created for each entry and a '--config=$CONFIGURATION' will
        be appended to the underlying bazel invocation. Effectively allowing the configs in the .bazelrc file
        to control how Xcode builds each build configuration.

        If not present the 'Debug' and 'Release' Xcode build configurations will be created by default without
        appending any additional bazel invocation flags.
        """),
        "target_settings_by_config": attr.string_list_dict(default = {}, doc = """
        Additional optinal dictionary with Xcode build settings to be added to all targets grouped by config (see 'configs' attribute).

        Example:

        target_settings_by_config = {
            "my_config": [
                "PRODUCT_BUNDLE_IDENTIFIER=com.company.app.my_config",
                "FOO=bar_1",
            ]
            "Release": [
                "PRODUCT_BUNDLE_IDENTIFIER=com.company.app",
                "FOO=bar_2",
            ],
        }

        Each config has to exist in 'configs' and be set to one of 'debug'/'release' so xcodegen knows about its existence when creating the target.

        Also, note that bazel doesn't support attributes with strings as keys and values at dictionaries so the proposal here is
        to pass the settings as an array of strings where each element has the format 'SETTING_NAME=VALUE'.

        Read more:
        - https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md#settings
        - https://docs.bazel.build/versions/main/skylark/lib/attr.html

        """),
        "deps": attr.label_list(mandatory = True, allow_empty = False, providers = [], aspects = [_xcodeproj_aspect]),
        "include_transitive_targets": attr.bool(default = False, mandatory = False),
        "project_name": attr.string(mandatory = False),
        "output_path": attr.string(mandatory = False, default = "", doc = """
        The output path to use when generating the xcode project.
        Must be a relative path beneath the package where the xcodeproj rule is defined
        """),
        "bazel_path": attr.string(mandatory = False, default = "bazel"),
        "scheme_existing_envvar_overrides": attr.string_dict(allow_empty = True, default = {}, mandatory = False),
        "project_attributes_overrides": attr.string_dict(allow_empty = True, mandatory = False, default = {}, doc = "Overrides for attributes that can be set at the project base level."),
        "project_options_overrides": attr.label(mandatory = False, providers = [_ProjectOptionsInfo], doc = "Overrides for options that can be set at the project base level. Use 'xcodeproj_project_options'."),
        "additional_scheme_infos": attr.label_list(mandatory = False, allow_empty = True, providers = [], aspects = [], doc = """
        List of additional_scheme_info labels that append scheme information to the generated scheme for a build target.
        Currently supports test actions, and test environment variables.
"""),
        "generate_schemes_for_product_types": attr.string_list(mandatory = False, allow_empty = True, default = [], doc = """\
Generate schemes only for the specified product types if this list is not empty.
Product types must be valid apple product types, e.g. application, bundle.unit-test, framework.
For a full list, see under keys of `PRODUCT_TYPE_UTI` under
https://www.rubydoc.info/github/CocoaPods/Xcodeproj/Xcodeproj/Constants
"""),
        "_xcodeproj_installer_template": attr.label(executable = False, default = Label("//tools/xcodeproj_shims:xcodeproj-installer.sh"), allow_single_file = ["sh"]),
        "_workspace_xcsettings": attr.label(executable = False, default = Label("//tools/xcodeproj_shims:WorkspaceSettings.xcsettings"), allow_single_file = ["xcsettings"]),
        "_workspace_checks": attr.label(executable = False, default = Label("//tools/xcodeproj_shims:IDEWorkspaceChecks.plist"), allow_single_file = ["plist"]),
        "output_processor": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:output-processor.rb"), cfg = "exec", allow_single_file = True),
        "_xcodegen": attr.label(executable = True, default = Label("@com_github_yonaskolb_xcodegen//:xcodegen"), cfg = "exec"),
        "index_import": attr.label(executable = True, default = Label("@build_bazel_rules_swift_index_import//:index_import"), cfg = "exec"),
        "clang_stub": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:clang-stub"), cfg = "exec"),
        "ld_stub": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:ld-stub"), cfg = "exec"),
        "swiftc_stub": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:swiftc-stub"), cfg = "exec"),
        "print_json_leaf_nodes": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:print_json_leaf_nodes"), cfg = "exec"),
        "installer": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:installer"), cfg = "exec"),
        "build_wrapper": attr.label(executable = True, default = Label("//tools/xcodeproj_shims:build-wrapper"), cfg = "exec"),
        "additional_files": attr.label_list(allow_files = True, allow_empty = True, default = [], mandatory = False),
        "additional_prebuild_script": attr.string(default = "", mandatory = False),  # Note this script will run BEFORE Bazel build script
        "additional_bazel_build_options": attr.string_list(default = [], mandatory = False),
        "additional_pre_actions": attr.string_list_dict(default = {}, mandatory = False, doc = """
Configure a list of pre-actions for build/run/test in each scheme generated.
For each entry the key is one of build/test/run and value is a list of scripts.
And it will not surface any error or output through build log.
        """),
        "additional_post_actions": attr.string_list_dict(default = {}, mandatory = False, doc = """
Configure a list of post-actions for build/run/test in each scheme generated.
For each entry the key is one of build/test/run and value is a list of scripts.
And it will not surface any error or output through build log.
        """),
        "provide_build_settings_from_target_for_pre_post_actions": attr.bool(default = False, mandatory = False),
        "additional_lldb_settings": attr.string_list(default = [], mandatory = False, doc = """
Additional LLDB settings to be added in each target's .lldbinit configuration file.
        """),
        "bazel_execution_log_enabled": attr.bool(default = False, mandatory = False),
        "bazel_profile_enabled": attr.bool(default = False, mandatory = False),
        "disable_main_thread_checker": attr.bool(default = False, mandatory = False),
        "force_x86_sim": attr.bool(default = False, mandatory = False),
    },
    executable = True,
)
