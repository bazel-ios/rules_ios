load("@build_bazel_rules_apple//apple:providers.bzl", "AppleFrameworkImportInfo")
load("@build_bazel_rules_apple//apple:providers.bzl", "AppleBundleInfo", "AppleSupportToolchainInfo")

_Provider = provider(fields = {
    "imported_library_files": "",
    "static_framework_files": "",
    "dynamic_framework_files": "",
})

def _do_framework(ctx, framework):
    # Enusre that this will correctly propagate all framework files
    out_file = ctx.actions.declare_file(framework.basename + ".framework" + "/" + framework.basename)
    out_dir = ctx.actions.declare_file(framework.basename + ".framework")
    cmd = """
     set -e

     TOOL="external/build_bazel_rules_ios/tools/m1_utils/{}.sh"
     FRAMEWORK_BINARY="{}"
     OUT_DIR="{}"
     FW_DIR="$(dirname "$FRAMEWORK_BINARY")"

     # Duplicate the _entire_ input framework
     mkdir -p "$(dirname "$OUT_DIR")"

     ditto "$FW_DIR" "$OUT_DIR"
     "$TOOL" "$OUT_DIR/$(basename "$FRAMEWORK_BINARY")"
   """.format(ctx.executable.update_in_place.basename, framework.path, out_dir.path)

    ctx.actions.run_shell(outputs = [out_file, out_dir], inputs = depset([framework]), command = cmd)
    return out_file

def _do_lib(ctx, imported_library):
    # Enusre that this will correctly propagate all framework files
    out_file = ctx.actions.declare_file(imported_library.basename)
    cmd = """
     set -e

     TOOL="external/build_bazel_rules_ios/tools/m1_utils/{}.sh"
     BINARY="{}"
     OUT="{}"

     # Duplicate the _entire_ input framework
     mkdir -p "$(dirname "$BINARY")"

     ditto "$BINARY" "$OUT"
     "$TOOL" "$OUT"
   """.format(ctx.executable.update_in_place.basename, imported_library.path, out_file.path)

    ctx.actions.run_shell(outputs = [out_file], inputs = depset([imported_library]), command = cmd)
    return out_file

def _add_to_dict_if_present(dict, key, value):
    if value:
        dict[key] = value

def _make_imports(transitive_sets):
    provider_fields = {}
    if transitive_sets:
        provider_fields["framework_imports"] = depset(transitive = transitive_sets)
    provider_fields["build_archs"] = depset(["arm64"])
    provider_fields["debug_info_binaries"] = depset(transitive_sets)

    # FIXME: probably just pass along the dsyms? We may need to rework the provider a bit
    provider_fields["dsym_imports"] = depset()
    return AppleFrameworkImportInfo(**provider_fields)

def _find_imports_impl(target, ctx):
    # Collect trans swift_library outputs
    static_framework_files = []
    imported_library_files = []
    dynamic_framework_files = []

    # FIXME: update merging to remove to_list()
    if _Provider in target:
        static_framework_files.extend(target[_Provider].static_framework_files.to_list())
        dynamic_framework_files.extend(target[_Provider].dynamic_framework_files.to_list())

    # FIXME: do we really need to deal with this
    deps_to_search = []
    if hasattr(ctx.rule.attr, "deps"):
        deps_to_search = ctx.rule.attr.deps
    if hasattr(ctx.rule.attr, "transitive_deps"):
        deps_to_search = deps_to_search + ctx.rule.attr.transitive_deps

    static_framework_file = depset()
    dynamic_framework_file = depset()
    for dep in deps_to_search:
        if _Provider in dep:
            # FIXME: update merging to use depset
            static_framework_files.extend(dep[_Provider].static_framework_files.to_list())
            imported_library_files.extend(dep[_Provider].imported_library_files.to_list())
            dynamic_framework_files.extend(dep[_Provider].dynamic_framework_files.to_list())

 
        # FIXME: Probably not necessary
        if AppleFrameworkImportInfo in dep:
            static_framework_files.extend(dep[apple_common.Objc].static_framework_file.to_list())
            dynamic_framework_files.extend(dep[apple_common.Objc].dynamic_framework_file.to_list())

    # FIXME: update merging to use depset
    if ctx.rule.kind == "objc_import":
        imported_library_files.extend(target[apple_common.Objc].imported_library.to_list())
    elif AppleFrameworkImportInfo in target:
        static_framework_files.extend(target[apple_common.Objc].static_framework_file.to_list())
        dynamic_framework_files.extend(target[apple_common.Objc].dynamic_framework_file.to_list())

    return [_Provider(
        dynamic_framework_files = depset(dynamic_framework_files),
        imported_library_files = depset(imported_library_files),
        static_framework_files = depset(static_framework_files),
    )]

find_imports = aspect(
    implementation = _find_imports_impl,
    attr_aspects = ["transitve_deps", "deps", "srcs"],
)

def _file_collector_rule_impl(ctx):
    # Merge depsets - consider doing this a better way
    all_static_framework_files = []
    all_imported_library_files = []
    all_dynamic_framework_files = []
    for dep in ctx.attr.deps:
        if _Provider in dep:
            all_static_framework_files.extend(dep[_Provider].static_framework_files.to_list())
            all_imported_library_files.extend(dep[_Provider].imported_library_files.to_list())
            all_dynamic_framework_files.extend(dep[_Provider].dynamic_framework_files.to_list())
    input_static_frameworks = depset(all_static_framework_files).to_list()
    input_imported_librarys = depset(all_imported_library_files).to_list()
    input_dynamic_frameworks = depset(all_dynamic_framework_files).to_list()

    objc_provider_fields = {}

    for key in [
        "sdk_dylib",
        "sdk_framework",
        "weak_sdk_framework",
        "imported_library",
        "force_load_library",
        # Note(Bazel5): This is no longer supported
        #"multi_arch_linked_archives",
        #"multi_arch_linked_binaries",
        #"multi_arch_dynamic_libraries",
        "source",
        "link_inputs",
        "linkopt",
        "library",
        "dynamic_framework_file",
        "static_framework_file",
    ]:
        set = depset(
            direct = [],
            # Note:  we may want to merge this with the below inputs?
            transitive = [getattr(dep[apple_common.Objc], key) for dep in ctx.attr.deps],
        )
        _add_to_dict_if_present(objc_provider_fields, key, set)

    # Build out the imported libraries replacing each one along the way
    filtered_libs = []
    existing_libs = {}
    for li in input_imported_librarys:
        existing_libs[li.path] = True
        filtered_libs.append(_do_lib(ctx, li))

    exisiting_imported_librarys = objc_provider_fields["imported_library"]
    for li in exisiting_imported_librarys.to_list():
        if not existing_libs.get(li.path, False):
            filtered_libs.append(li)

    objc_provider_fields["imported_library"] = depset(filtered_libs)

    # Build out framework inputs
    # FIXME: this should follow the above logic, or simplify
    static_framework_files = [_do_framework(ctx, f) for f in input_static_frameworks]
    dynamic_framework_files = [_do_framework(ctx, f) for f in input_dynamic_frameworks]
    all_frameworks = static_framework_files + dynamic_framework_files

    # FIXME: see above comment
    objc_provider_fields["linkopt"] = depset(
        ["\"-F" + "/".join(f.path.split("/")[:-2]) + "\"" for f in all_frameworks],
        transitive = [
            objc_provider_fields["linkopt"],
        ],
    )
    objc_provider_fields["link_inputs"] = depset(
        transitive = [
            objc_provider_fields["link_inputs"],
            depset(static_framework_files + dynamic_framework_files),
        ],
    )
    objc_provider_fields["static_framework_file"] = depset(transitive = [
        objc_provider_fields["static_framework_file"],
        depset(static_framework_files),
    ])
    objc_provider_fields["dynamic_framework_file"] = depset(dynamic_framework_files)

    objc = apple_common.new_objc_provider(
        **objc_provider_fields
    )

    return [
        objc,
        _make_imports([depset(dynamic_framework_files)]),
    ]

import_middleman = rule(
    implementation = _file_collector_rule_impl,
    attrs = {
        "deps": attr.label_list(aspects = [find_imports]),
        "update_in_place": attr.label(executable = True, default = Label("//tools/m1_utils:update_in_place"), cfg = "host"),
    },
)
