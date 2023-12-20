load("//rules:providers.bzl", "AvoidDepsInfo")
load("//rules:transition_support.bzl", "split_transition_rule_attrs", "transition_support")
load("@bazel_skylib//lib:dicts.bzl", "dicts")

def _force_load_direct_deps_impl(ctx):
    if not ctx.attr.should_force_load:
        return [apple_common.new_objc_provider(), CcInfo()]

    force_load = []

    avoid_deps = []
    for dep in ctx.attr.deps:
        if AvoidDepsInfo in dep:
            avoid_deps.extend(dep[AvoidDepsInfo].libraries)

    avoid_libraries = {}
    for dep in avoid_deps:
        if CcInfo in dep:
            for linker_input in dep[CcInfo].linking_context.linker_inputs.to_list():
                for lib in linker_input.libraries:
                    avoid_libraries[lib] = True

    force_load = []
    for dep in ctx.attr.deps:
        if CcInfo in dep:
            for linker_input in dep[CcInfo].linking_context.linker_inputs.to_list():
                for lib in linker_input.libraries:
                    if not lib in avoid_libraries:
                        force_load.append(lib)

    static_libraries = [lib.static_library for lib in force_load if lib.static_library != None]
    return [
        apple_common.new_objc_provider(
            force_load_library = depset(static_libraries),
            link_inputs = depset(static_libraries),
        ),
        CcInfo(
            linking_context = cc_common.create_linking_context(
                linker_inputs = depset([
                    cc_common.create_linker_input(
                        owner = ctx.label,
                        libraries = depset([
                            cc_common.create_library_to_link(
                                actions = ctx.actions,
                                static_library = lib,
                                alwayslink = True,
                            )
                            for lib in static_libraries
                        ]),
                        additional_inputs = depset(static_libraries),
                    ),
                ]),
            ),
        ),
    ]

force_load_direct_deps = rule(
    implementation = _force_load_direct_deps_impl,
    attrs = dicts.add(split_transition_rule_attrs, {
        "deps": attr.label_list(
            cfg = transition_support.split_transition,
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
    }),
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
