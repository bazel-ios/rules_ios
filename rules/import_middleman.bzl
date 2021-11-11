load("@build_bazel_rules_apple//apple:providers.bzl", "AppleFrameworkImportInfo")
load("@build_bazel_rules_apple//apple:providers.bzl", "AppleBundleInfo", "AppleSupportToolchainInfo")

_Provider = provider(fields = {
    "imported_library_files": "",
    "static_framework_files": "",
    "dynamic_framework_files": "",
    "import_infos": "",
})

def _do_framework(ctx, framework):
    # Enusre that this will correctly propagate all framework files
    out_file = ctx.actions.declare_file(ctx.attr.name + "/" + framework.basename + ".framework" + "/" + framework.basename)
    out_dir = ctx.actions.declare_file(ctx.attr.name + "/" + framework.basename + ".framework")
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

    ctx.actions.run_shell(outputs = [out_dir, out_file], inputs = depset([framework]), command = cmd)
    return out_file

def _do_lib(ctx, imported_library):
    # Enusre that this will correctly propagate all framework files
    out_file = ctx.actions.declare_file(ctx.attr.name + "/" + imported_library.basename)
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
    import_infos = {}

    if _Provider in target:
        static_framework_files.append(target[_Provider].static_framework_files)
        imported_library_files.append(target[_Provider].static_framework_files)
        dynamic_framework_files.append(target[_Provider].dynamic_framework_files)
        import_infos.update(target[_Provider].import_infos)

    deps_to_search = []
    if hasattr(ctx.rule.attr, "deps"):
        deps_to_search = ctx.rule.attr.deps
    if hasattr(ctx.rule.attr, "transitive_deps"):
        deps_to_search = deps_to_search + ctx.rule.attr.transitive_deps

    static_framework_file = depset()
    dynamic_framework_file = depset()
    for dep in deps_to_search:
        if _Provider in dep:
            static_framework_files.append(dep[_Provider].static_framework_files)
            imported_library_files.append(dep[_Provider].imported_library_files)
            dynamic_framework_files.append(dep[_Provider].dynamic_framework_files)
            import_infos.update(dep[_Provider].import_infos)

    if ctx.rule.kind == "objc_import":
        imported_library_files.append(target[apple_common.Objc].imported_library)
    elif AppleFrameworkImportInfo in target:
        static_framework_files.append(target[apple_common.Objc].static_framework_file)

        dynamic_framework_file = target[apple_common.Objc].dynamic_framework_file
        dynamic_framework_file_list = df.to_list()
        if len(df_list) > 0:
            import_infos[dynamic_framework_file_list[0].path] = target[AppleFrameworkImportInfo]

        dynamic_framework_files.append(dynamic_framework_file)

    return [_Provider(
        dynamic_framework_files = depset(transitive = dynamic_framework_files),
        imported_library_files = depset(transitive = imported_library_files),
        static_framework_files = depset(transitive = static_framework_files),
        import_infos = import_infos,
    )]

find_imports = aspect(
    implementation = _find_imports_impl,
    attr_aspects = ["transitve_deps", "deps", "srcs"],
)

def _file_collector_rule_impl(ctx):
    # Merge depsets - consider doing this a better way
    all_static_framework_files = [depset()]
    all_imported_library_files = [depset()]
    all_dynamic_framework_files = [depset()]
    all_import_infos = {}
    for dep in ctx.attr.deps:
        if _Provider in dep:
            all_static_framework_files.append(dep[_Provider].static_framework_files)
            all_imported_library_files.append(dep[_Provider].imported_library_files)
            all_dynamic_framework_files.append(dep[_Provider].dynamic_framework_files)
            all_import_infos.update(dep[_Provider].import_infos)

    input_static_frameworks = depset(transitive = all_static_framework_files).to_list()
    input_imported_librarys = depset(transitive = all_imported_library_files).to_list()
    input_dynamic_frameworks = depset(transitive = all_dynamic_framework_files).to_list()

    objc_provider_fields = {}

    for key in [
        "sdk_dylib",
        "sdk_framework",
        "weak_sdk_framework",
        "imported_library",
        "force_load_library",
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

    exisiting_imported_librarys = objc_provider_fields.get("imported_library", depset([]))
    for li in exisiting_imported_librarys.to_list():
        if not existing_libs.get(li.path, False):
            filtered_libs.append(li)

    objc_provider_fields["imported_library"] = depset(filtered_libs)

    # Build out framework inputs
    # FIXME: this should follow the above logic, or simplify
    static_framework_files = [_do_framework(ctx, f) for f in input_static_frameworks]

    print("All imports", all_import_infos)
    dynamic_framework_files = []
    dynamic_framework_dirs = []
    for f in depset(input_dynamic_frameworks).to_list():
        out = _do_framework(ctx, f)
        dynamic_framework_files.append(out)
        dynamic_framework_dirs.append(out)
        ad_hoc_files = all_import_infos[f.path].framework_imports.to_list()

        # Remove the input framework files from this rule
        # Perhaps we should put this logic into do_framework
        # It's specific to dynamic
        ad_hoc_files.remove(f)
        dynamic_framework_dirs.extend(ad_hoc_files)

    all_frameworks = static_framework_files + dynamic_framework_files

    # TODO: see above comment
    objc_provider_fields["linkopt"] = depset(
        ["\"-F" + "/".join(f.path.split("/")[:-2]) + "\"" for f in static_framework_files],
        transitive = [
            objc_provider_fields.get("linkopt", depset([])),
        ],
    )
    objc_provider_fields["link_inputs"] = depset(
        transitive = [
            objc_provider_fields.get("link_inputs", depset([])),
            depset(static_framework_files + dynamic_framework_files),
        ],
    )
    objc_provider_fields["static_framework_file"] = depset(transitive = [
        objc_provider_fields.get("static_framework_file", depset([])),
        depset(static_framework_files),
    ])

    objc_provider_fields["dynamic_framework_file"] = depset(transitive = [
        objc_provider_fields.get("dynamic_framework_file", depset([])),
        depset(dynamic_framework_files),
    ])

    objc = apple_common.new_objc_provider(
        **objc_provider_fields
    )

    return [
        DefaultInfo(files = depset(dynamic_framework_dirs)),
        objc,
        _make_imports([depset(dynamic_framework_dirs)]),
    ]

import_middleman = rule(
    implementation = _file_collector_rule_impl,
    attrs = {
        "deps": attr.label_list(aspects = [find_imports]),
        "update_in_place": attr.label(executable = True, default = Label("//tools/m1_utils:update_in_place"), cfg = "host"),
    },
)
