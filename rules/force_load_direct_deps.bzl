load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("//rules:providers.bzl", "AvoidDepsInfo")
load("//rules:transition_support.bzl", "transition_support")

def _objc_provider_static_libraries(dep):
    """Returns the ObjcProvider static libraries (.a) that should be force loaded.
    """
    if not apple_common.Objc in dep:
        return []

    return dep[apple_common.Objc].library.to_list()

def _cc_info_static_libraries(dep):
    """Returns the CcInfo static libraries (.a) that should be force loaded.

    NOTE: CcInfo, unlike ObjcProvider, does not encode where the static library came from.
    In the existing `_objc_provider_static_libraries` we only collect `.library` from ObjcProvider.
    ObjcProvider `.library` list static library dependencies of the current target,
    it does not include imported static libraries (such as those from `.framework` files).
    CcInfo only provides `.static_library` and does not make this distinction.
    To match this behavior, we only collect `.static_library` from CcInfo that are not from `.framework`s.
    """
    if not CcInfo in dep:
        return []

    static_cc_libraries = []
    for linker_input in dep[CcInfo].linking_context.linker_inputs.to_list():
        for library_to_link in linker_input.libraries:
            if not library_to_link.static_library:
                continue
            containing_path = paths.dirname(library_to_link.static_library.path)
            if containing_path.endswith(".framework"):
                continue
            static_cc_libraries.append(library_to_link.static_library)

    return static_cc_libraries

# TODO: We should deprecate this rule for Bazel 7+ as `--incompatible_objc_alwayslink_by_default` effectively
#       does the same thing.
def _force_load_direct_deps_impl(ctx):
    """This rule will traverse the direct deps of the target and force load the static libraries of the objc deps.
    """

    if not ctx.attr.should_force_load:
        return [
            apple_common.new_objc_provider(),
            CcInfo(),
        ]

    force_load_libraries = []
    force_load_cc_libraries = []
    avoid_deps = []
    avoid_libraries = {}
    avoid_cc_libraries = {}
    cc_toolchain = find_cpp_toolchain(ctx)
    cc_features = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        language = "objc",
    )

    # Set the deps that should be avoided and not linked.
    for dep in ctx.attr.deps:
        if AvoidDepsInfo in dep:
            avoid_deps.extend(dep[AvoidDepsInfo].libraries)

    # Collect the libraries that should be avoided.
    for dep in avoid_deps:
        for lib in _objc_provider_static_libraries(dep):
            avoid_libraries[lib] = True
        for lib in _cc_info_static_libraries(dep):
            avoid_cc_libraries[lib] = True

    # Collect the libraries that should be force loaded.
    for dep in ctx.attr.deps:
        for lib in _objc_provider_static_libraries(dep):
            if not lib in avoid_libraries:
                force_load_libraries.append(lib)
        for lib in _cc_info_static_libraries(dep):
            if not lib in avoid_cc_libraries:
                force_load_cc_libraries.append(lib)

    return [
        apple_common.new_objc_provider(
            force_load_library = depset(force_load_libraries),
            link_inputs = depset(force_load_libraries),
        ),
        CcInfo(
            linking_context = cc_common.create_linking_context(
                linker_inputs = depset([
                    cc_common.create_linker_input(
                        owner = ctx.label,
                        libraries = depset([
                            cc_common.create_library_to_link(
                                actions = ctx.actions,
                                cc_toolchain = cc_toolchain,
                                feature_configuration = cc_features,
                                static_library = library,
                                alwayslink = True,
                            )
                            for library in force_load_cc_libraries
                        ]),
                    ),
                ]),
            ),
        ),
    ]

force_load_direct_deps = rule(
    implementation = _force_load_direct_deps_impl,
    toolchains = use_cpp_toolchain(),
    fragments = ["apple", "cpp", "objc"],
    attrs = {
        "deps": attr.label_list(
            cfg = transition_support.apple_platform_split_transition,
            mandatory = True,
            doc =
                "Deps",
        ),
        "should_force_load": attr.bool(
            default = True,
            doc = "Allows parametrically enabling the functionality in this rule.",
        ),
        "platform_type": attr.string(
            mandatory = False,
            doc =
                """Internal - currently rules_ios uses the dict `platforms`
""",
        ),
        "minimum_os_version": attr.string(
            mandatory = False,
            doc =
                """Internal - currently rules_ios the dict `platforms`
""",
        ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
            doc = "Needed to allow this rule to have an incoming edge configuration transition.",
        ),
        "_cc_toolchain": attr.label(
            providers = [cc_common.CcToolchainInfo],
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
            doc = """\
The C++ toolchain from which linking flags and other tools needed by the Swift
toolchain (such as `clang`) will be retrieved.
""",
        ),
    },
    doc = """
A rule to link with `-force_load` for direct`deps`

ld has different behavior when loading members of a static library VS objects
as far as visibility. Under `-dynamic`
- linked _swift object files_ can have public visibility
- symbols from _swift static libraries_ are omitted unless used, and not
visible otherwise

By using `-force_load`, we can load static libraries in the attributes of an
application's direct depenencies. These args need go at the _front_ of the
linker invocation otherwise these arguments don't work with lds logic.

Why not put it into `rules_apple`? Ideally it could be, and perhaps consider a
PR to there .The underlying java rule, `AppleBinary.linkMultiArchBinary`
places `extraLinkopts` at the end of the linker invocation. At the time of
writing these args need to go into the current rule context where
`AppleBinary.linkMultiArchBinary` is called.

One use case of this is that iOS developers want to load above mentioned
symbols from applications. Another alternate could be to create an aspect,
that actually generates a different application and linker invocation instead
of force loading symbols. This could be more complicated from an integration
perspective so it isn't used.

    """,
)
