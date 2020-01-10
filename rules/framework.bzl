load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_skylib//lib:types.bzl", "types")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo")
load("//rules:library.bzl", "PrivateHeaders", "apple_library")
load("//rules/vfs_overlay:vfs_overlay.bzl", "VFSOverlay")

def apple_framework(name, apple_library = apple_library, **kwargs):
    """
    Builds and packages an Apple framework.

    Args:
        name: The name of the framework.
        apple_library: The macro used to package sources into a library.
        kwargs: Arguments passed to the apple_library and apple_framework_packaging rules as appropriate.
    """
    library = apple_library(name = name, **kwargs)
    args = {
        "name": name,
        "deps": library.lib_names,
        "visibility": kwargs.get("visibility", None),
        "tags": kwargs.get("tags", None),
    }
    if kwargs.get("srcs", None) or kwargs.get("non_arc_srcs", None):
        apple_framework_packaging(
            framework_name = library.module_name,
            transitive_deps = library.transitive_deps,
            **args
        )
    else:
        native.objc_library(**args)

def _framework_packaging(ctx, framework_dir, action, inputs, outputs):
    if not inputs:
        return []
    if inputs == [None]:
        return []
    framework_name = ctx.attr.framework_name
    args = ctx.actions.args().use_param_file("@%s").set_param_file_format("multiline")
    args.add("--framework_name", framework_name)
    args.add("--framework_root", framework_dir)
    args.add("--action", action)
    args.add_all("--inputs", inputs)
    args.add_all("--outputs", outputs)
    ctx.actions.run(
        executable = ctx.executable._framework_packaging,
        arguments = [args],
        inputs = inputs,
        outputs = outputs,
        mnemonic = "PackagingFramework%s" % action.title().replace("_", ""),
    )
    return outputs

def _apple_framework_packaging_impl(ctx):
    framework_name = ctx.attr.framework_name

    # declare framework directory
    framework_dir = "%s/%s.framework" % (ctx.attr.name, framework_name)

    # binaries
    binary_in = []
    binary_out = ctx.actions.declare_file(
        paths.join(framework_dir, framework_name),
    )
    framework_root = binary_out.dirname

    # headers
    header_in = []
    header_out = []

    private_header_in = []
    private_header_out = []

    file_map = []

    # modulemap
    modulemap_in = None
    modulemap_out = ctx.actions.declare_file(
        paths.join(framework_dir, "Modules", "module.modulemap"),
    )

    # headermaps
    header_maps = []

    # current build architecture
    arch = ctx.fragments.apple.single_arch_cpu

    # swift specific artifacts
    swiftmodule_in = None
    swiftmodule_out = None
    swiftdoc_in = None
    swiftdoc_out = None

    # collect files
    for dep in ctx.attr.deps:
        for file in dep.files.to_list():
            if file.is_source:
                continue

            # collect binary files
            if file.path.endswith(".a"):
                binary_in.append(file)

            # collect swift specific files
            if file.path.endswith(".swiftmodule"):
                swiftmodule_in = file
                swiftmodule_out = ctx.actions.declare_file(
                    paths.join(
                        framework_dir,
                        "Modules",
                        framework_name + ".swiftmodule",
                        arch + ".swiftmodule",
                    ),
                )
            if file.path.endswith(".swiftdoc"):
                swiftdoc_in = file
                swiftdoc_out = ctx.actions.declare_file(
                    paths.join(
                        framework_dir,
                        "Modules",
                        framework_name + ".swiftmodule",
                        arch + ".swiftdoc",
                    ),
                )

        if PrivateHeaders in dep:
            for hdr in dep[PrivateHeaders].headers.to_list():
                private_header_in.append(hdr)
                destination = ctx.actions.declare_file(
                    paths.join(framework_dir, "PrivateHeaders", hdr.basename),
                )
                private_header_out.append(destination)
                file_map.append((hdr, destination))

        if apple_common.Objc in dep:
            # collect headers
            for hdr in dep[apple_common.Objc].direct_headers:
                if hdr.path.endswith((".h", ".hh")):
                    header_in.append(hdr)
                    destination = ctx.actions.declare_file(
                        paths.join(framework_dir, "Headers", hdr.basename),
                    )
                    header_out.append(destination)
                    file_map.append((hdr, destination))

            # collect modulemaps
            for modulemap in dep[apple_common.Objc].direct_module_maps:
                modulemap_in = modulemap

    # if not binary_in:
    #     fail("%s cannot package a framework, it contains no binaries (deps %s)" % (ctx.attr.name, ctx.attr.deps))

    # Package each part of the framework separately,
    # so inputs that do not depend on compilation
    # are available before those that do,
    # improving parallelism
    framework_files = []
    framework_files += _framework_packaging(ctx, framework_root, "binary", binary_in, [binary_out])
    framework_files += _framework_packaging(ctx, framework_root, "modulemap", [modulemap_in], [modulemap_out])
    framework_files += _framework_packaging(ctx, framework_root, "header", header_in, header_out)
    framework_files += _framework_packaging(ctx, framework_root, "private_header", private_header_in, private_header_out)
    framework_files += _framework_packaging(ctx, framework_root, "swiftmodule", [swiftmodule_in], [swiftmodule_out])
    framework_files += _framework_packaging(ctx, framework_root, "swiftdoc", [swiftdoc_in], [swiftdoc_out])

    # headermap
    mappings_file = ctx.actions.declare_file(framework_name + "_framework.hmap.txt")
    mappings = []
    for header in header_in + private_header_in:
        mappings.append(framework_name + "/" + header.basename + "|" + header.path)

    # write mapping for hmap tool
    ctx.actions.write(
        content = "\n".join(mappings) + "\n",
        output = mappings_file,
    )

    # write headermap
    hmap_file = ctx.actions.declare_file(framework_name + "_framework_public_hmap.hmap")
    ctx.actions.run(
        inputs = [mappings_file],
        mnemonic = "HmapCreate",
        arguments = [mappings_file.path, hmap_file.path],
        executable = ctx.executable._headermap_builder,
        outputs = [hmap_file],
    )

    objc_provider_fields = {
        "static_framework_file": depset(
            direct = [binary_out],
        ),
        "header": depset(
            direct = header_out + private_header_out + [modulemap_out, hmap_file],
        ),
        "module_map": depset(
            direct = [modulemap_out],
        ),
        "framework_search_paths": depset(
            direct = [framework_root],
        ),
        "providers": [dep[apple_common.Objc] for dep in ctx.attr.transitive_deps],
    }
    for key in [
        "sdk_dylib",
        "sdk_framework",
        "weak_sdk_framework",
        "imported_library",
        "force_load_library",
        "multi_arch_linked_archives",
        "source",
        "define",
        "include",
    ]:
        set = depset(
            direct = [],
            transitive = [getattr(dep[apple_common.Objc], key) for dep in ctx.attr.deps],
        )
        if set:
            objc_provider_fields[key] = set

    objc_provider = apple_common.new_objc_provider(**objc_provider_fields)
    default_info_provider = DefaultInfo(files = depset(framework_files))
    # vfs_overlay_provider = VFSOverlay(
    #     files = depset(items = file_map, transitive = [dep[VFSOverlay].files for dep in ctx.attr.transitive_deps if VFSOverlay in dep])
    # )

    return [objc_provider, default_info_provider]

apple_framework_packaging = rule(
    implementation = _apple_framework_packaging_impl,
    fragments = ["apple"],
    output_to_genfiles = True,
    attrs = {
        "framework_name": attr.string(
            mandatory = True,
            doc =
                """Name of the framework, usually the same as the module name
""",
        ),
        "deps": attr.label_list(
            mandatory = True,
            doc =
                """Objc or Swift rules to be packed by the framework rule
""",
        ),
        "transitive_deps": attr.label_list(
            mandatory = True,
            doc =
                """Deps of the deps
""",
        ),
        "_framework_packaging": attr.label(
            cfg = "host",
            default = Label(
                "//rules/framework:framework_packaging",
            ),
            executable = True,
        ),
        "_headermap_builder": attr.label(
            executable = True,
            cfg = "host",
            default = Label(
                "//rules/hmap:hmaptool",
            ),
        ),
    },
    doc = "Packages compiled code into an Apple .framework package",
)
