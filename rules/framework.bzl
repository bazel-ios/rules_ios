"""Framework rules"""

load("@build_bazel_rules_apple//apple/internal:apple_product_type.bzl", "apple_product_type")
load("@build_bazel_rules_apple//apple:providers.bzl", "AppleBundleInfo")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@build_bazel_rules_swift//swift:swift.bzl", "SwiftInfo", "swift_common")
load("//rules:library.bzl", "PrivateHeadersInfo", "apple_library")
load("//rules:transition_support.bzl", "transition_support")

_APPLE_FRAMEWORK_PACKAGING_KWARGS = [
    "visibility",
    "tags",
    "bundle_id",
    "skip_packaging",
]

def apple_framework(name, apple_library = apple_library, **kwargs):
    """Builds and packages an Apple framework.

    Args:
        name: The name of the framework.
        apple_library: The macro used to package sources into a library.
        **kwargs: Arguments passed to the apple_library and apple_framework_packaging rules as appropriate.
    """
    framework_packaging_kwargs = {arg: kwargs.pop(arg) for arg in _APPLE_FRAMEWORK_PACKAGING_KWARGS if arg in kwargs}
    library = apple_library(name = name, **kwargs)
    apple_framework_packaging(
        name = name,
        framework_name = library.namespace,
        transitive_deps = library.transitive_deps,
        deps = library.lib_names,
        platforms = library.platforms,
        **framework_packaging_kwargs
    )

def _find_framework_dir(outputs):
    for output in outputs:
        prefix = output.path.rsplit(".framework/", 1)[0]
        return prefix + ".framework"
    return None

def _framework_packaging(ctx, action, inputs, outputs, manifest = None):
    if not inputs:
        return []
    if inputs == [None]:
        return []
    if action in ctx.attr.skip_packaging:
        return []
    action_inputs = [manifest] + inputs if manifest else inputs
    outputs = [ctx.actions.declare_file(f) for f in outputs]
    framework_name = ctx.attr.framework_name
    framework_dir = _find_framework_dir(outputs)
    args = ctx.actions.args().use_param_file("@%s").set_param_file_format("multiline")
    args.add("--framework_name", framework_name)
    args.add("--framework_root", framework_dir)
    args.add("--action", action)
    args.add_all("--inputs", inputs)
    args.add_all("--outputs", outputs)
    ctx.actions.run(
        executable = ctx.executable._framework_packaging,
        arguments = [args],
        inputs = action_inputs,
        outputs = outputs,
        mnemonic = "PackagingFramework%s" % action.title().replace("_", ""),
    )
    return outputs

def _add_to_dict_if_present(dict, key, value):
    if value:
        dict[key] = value

def _concat(*args):
    arr = []
    for x in args:
        if x:
            arr += x
    return arr

def _apple_framework_packaging_impl(ctx):
    framework_name = ctx.attr.framework_name
    bundle_extension = ctx.attr.bundle_extension

    # declare framework directory
    framework_dir = "%s/%s.%s" % (ctx.attr.name, framework_name, bundle_extension)

    # binaries
    binary_in = []

    # headers
    header_in = []
    header_out = []

    private_header_in = []
    private_header_out = []

    file_map = []

    # modulemap
    modulemap_in = None

    # headermaps
    header_maps = []

    # current build architecture
    arch = ctx.fragments.apple.single_arch_cpu

    # swift specific artifacts
    swiftmodule_in = None
    swiftmodule_out = None
    swiftdoc_in = None
    swiftdoc_out = None

    # AppleBundleInfo fields
    bundle_id = ctx.attr.bundle_id
    infoplist = None
    current_apple_platform = transition_support.current_apple_platform(ctx.fragments.apple, ctx.attr._xcode_config)

    # collect files
    for dep in ctx.attr.deps:
        files = dep.files.to_list()
        for file in files:
            if file.is_source:
                continue

            # collect binary files
            if file.path.endswith(".a"):
                binary_in.append(file)

            # collect swift specific files
            if file.path.endswith(".swiftmodule"):
                swiftmodule_in = file
                swiftmodule_out = [paths.join(
                    framework_dir,
                    "Modules",
                    framework_name + ".swiftmodule",
                    arch + ".swiftmodule",
                )]
            if file.path.endswith(".swiftdoc"):
                swiftdoc_in = file
                swiftdoc_out = [paths.join(
                    framework_dir,
                    "Modules",
                    framework_name + ".swiftmodule",
                    arch + ".swiftdoc",
                )]

        if PrivateHeadersInfo in dep:
            for hdr in dep[PrivateHeadersInfo].headers.to_list():
                private_header_in.append(hdr)
                destination = paths.join(framework_dir, "PrivateHeaders", hdr.basename)
                private_header_out.append(destination)

        if apple_common.Objc in dep:
            # collect headers
            has_header = False
            for hdr in dep[apple_common.Objc].direct_headers:
                if hdr.path.endswith((".h", ".hh")):
                    has_header = True
                    header_in.append(hdr)
                    destination = paths.join(framework_dir, "Headers", hdr.basename)
                    header_out.append(destination)

            if not has_header:
                # only thing is the generated module map -- we don't want it
                continue

            if SwiftInfo in dep and dep[SwiftInfo].direct_modules:
                # apple_common.Objc.direct_module_maps is broken coming from swift_library
                # (it contains one level of transitive module maps), so ignore SwiftInfo from swift_library,
                # since it doesn't have a module_map field anyway
                continue

            # collect modulemaps
            for modulemap in dep[apple_common.Objc].direct_module_maps:
                if modulemap.owner == dep.label:
                    # module map is generated by the objc_library, and does not come
                    # from the attr
                    continue
                modulemap_in = modulemap

    binary_out = None
    modulemap_out = None
    if binary_in:
        binary_out = [
            paths.join(framework_dir, framework_name),
        ]
    if modulemap_in:
        modulemap_out = [
            paths.join(framework_dir, "Modules", "module.modulemap"),
        ]

    framework_manifest = ctx.actions.declare_file(framework_dir + ".manifest")

    # Package each part of the framework separately,
    # so inputs that do not depend on compilation
    # are available before those that do,
    # improving parallelism
    binary_out = _framework_packaging(ctx, "binary", binary_in, binary_out, framework_manifest)
    header_out = _framework_packaging(ctx, "header", header_in, header_out, framework_manifest)
    private_header_out = _framework_packaging(ctx, "private_header", private_header_in, private_header_out, framework_manifest)
    modulemap_out = _framework_packaging(ctx, "modulemap", [modulemap_in], modulemap_out, framework_manifest)
    swiftmodule_out = _framework_packaging(ctx, "swiftmodule", [swiftmodule_in], swiftmodule_out, framework_manifest)
    swiftdoc_out = _framework_packaging(ctx, "swiftdoc", [swiftdoc_in], swiftdoc_out, framework_manifest)
    framework_files = _concat(binary_out, modulemap_out, header_out, private_header_out, swiftmodule_out, swiftdoc_out)
    framework_root = _find_framework_dir(framework_files)

    if framework_root:
        ctx.actions.run(
            executable = ctx.executable._framework_packaging,
            arguments = [
                "--action",
                "clean",
                "--framework_name",
                framework_name,
                "--framework_root",
                framework_root,
                "--inputs",
                ctx.actions.args().use_param_file("%s", use_always = True).set_param_file_format("multiline")
                    .add_all(framework_files),
                "--outputs",
                framework_manifest.path,
            ],
            outputs = [framework_manifest],
            mnemonic = "CleaningFramework",
            execution_requirements = {
                "local": "True",
            },
        )
    else:
        ctx.actions.write(framework_manifest, "# Empty framework\n")

    # gather objc provider fields
    objc_provider_fields = {
        "providers": [dep[apple_common.Objc] for dep in ctx.attr.transitive_deps],
    }

    if framework_root:
        objc_provider_fields["framework_search_paths"] = depset(
            direct = [framework_root],
        )
    _add_to_dict_if_present(objc_provider_fields, "header", depset(
        direct = header_out + private_header_out + modulemap_out,
    ))
    _add_to_dict_if_present(objc_provider_fields, "module_map", depset(
        direct = modulemap_out,
    ))
    for key in [
        "sdk_dylib",
        "sdk_framework",
        "weak_sdk_framework",
        "imported_library",
        "force_load_library",
        "multi_arch_linked_archives",
        "multi_arch_linked_binaries",
        "multi_arch_dynamic_libraries",
        "source",
        "define",
        "include",
        "link_inputs",
        "linkopt",
        "library",
    ]:
        set = depset(
            direct = [],
            transitive = [getattr(dep[apple_common.Objc], key) for dep in ctx.attr.deps],
        )
        _add_to_dict_if_present(objc_provider_fields, key, set)

    # gather swift info fields
    swift_info_fields = {
        "swift_infos": [dep[SwiftInfo] for dep in ctx.attr.transitive_deps if SwiftInfo in dep],
    }

    if swiftmodule_out:
        # only add a swift module to the SwiftInfo if we've actually got a swiftmodule
        swiftmodule_name = paths.split_extension(swiftmodule_in.basename)[0]

        # need to include the swiftmodule here, even though it will be found through the framework search path,
        # since swift_library needs to know that the swiftdoc is an input to the compile action
        swift_module = swift_common.create_swift_module(
            swiftdoc = swiftdoc_out[0],
            swiftmodule = swiftmodule_out[0],
        )

        if swiftmodule_name != framework_name:
            # Swift won't find swiftmodule files inside of frameworks whose name doesn't match the
            # module name. It's annoying (since clang finds them just fine), but we have no choice but to point to the
            # original swift module/doc, so that swift can find it.
            swift_module = swift_common.create_swift_module(
                swiftdoc = swiftdoc_in,
                swiftmodule = swiftmodule_in,
            )

        swift_info_fields["modules"] = [
            # only add the swift module, the objc modulemap is already listed as a header,
            # and it will be discovered via the framework search path
            swift_common.create_module(name = swiftmodule_name, swift = swift_module),
        ]

    # Eventually we need to remove any reference to objc provider
    # and use CcInfo instead, see this issue for more details: https://github.com/bazelbuild/bazel/issues/10674
    objc_provider = apple_common.new_objc_provider(**objc_provider_fields)
    cc_info_provider = CcInfo(compilation_context = objc_provider.compilation_context)
    return [
        objc_provider,
        cc_common.merge_cc_infos(direct_cc_infos = [cc_info_provider], cc_infos = [dep[CcInfo] for dep in ctx.attr.transitive_deps if CcInfo in dep]),
        swift_common.create_swift_info(**swift_info_fields),
        # bare minimum to ensure compilation and package framework with modules and headers
        DefaultInfo(files = depset(binary_out + swiftmodule_out + header_out + private_header_out + modulemap_out)),
        AppleBundleInfo(
            archive = None,
            archive_root = None,
            binary = binary_out[0] if len(binary_out) > 0 else None,
            bundle_id = bundle_id,
            bundle_name = framework_name,
            bundle_extension = bundle_extension,
            entitlements = None,
            infoplist = infoplist,
            minimum_os_version = str(current_apple_platform.target_os_version),
            platform_type = str(current_apple_platform.platform.platform_type),
            product_type = ctx.attr._product_type,
            uses_swift = swiftmodule_out != None,
        ),
    ]

apple_framework_packaging = rule(
    implementation = _apple_framework_packaging_impl,
    cfg = transition_support.apple_rule_transition,
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
        "skip_packaging": attr.string_list(
            mandatory = False,
            default = [],
            allow_empty = True,
            doc = """Parts of the framework packaging process to be skipped.
Valid values are:
- "binary"
- "modulemap"
- "header"
- "private_header"
- "swiftmodule"
- "swiftdoc"
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
        "bundle_id": attr.string(
            mandatory = False,
            doc = "The bundle identifier of the framework. Currently unused.",
        ),
        "bundle_extension": attr.string(
            mandatory = False,
            default = "framework",
            doc = "The extension of the bundle, defaults to \"framework\".",
        ),
        "platforms": attr.string_dict(
            mandatory = False,
            default = {},
            doc = """A dictionary of platform names to minimum deployment targets.
If not given, the framework will be built for the platform it inherits from the target that uses
the framework as a dependency.""",
        ),
        "_product_type": attr.string(default = apple_product_type.static_framework),
        # TODO: allow customizing binary type between dynamic/static
        #         "binary_type": attr.string(
        #             default = "dylib",
        #         ),
        "_xcode_config": attr.label(
            default = configuration_field(
                name = "xcode_config_label",
                fragment = "apple",
            ),
            doc = "The xcode config that is used to determine the deployment target for the current platform.",
        ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
            doc = "Needed to allow this rule to have an incoming edge configuration transition.",
        ),
    },
    doc = "Packages compiled code into an Apple .framework package",
)
