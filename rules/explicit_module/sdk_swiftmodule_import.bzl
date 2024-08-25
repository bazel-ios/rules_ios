def _sdk_swiftmodule_import_impl(ctx):
    input_swiftmodule = ctx.attr.swiftmodule_path
    if not input_swiftmodule.startswith("/"):
        fail("The swiftmodule_path must be an absolute path")
    if not input_swiftmodule.endswith(".swiftmodule"):
        fail("Expect a .swiftmodule file, but got {}".format(input_swiftmodule))

    swfitmodule_name = "{}.swiftmodule".format(ctx.attr.module_name)
    output_swiftmodule = ctx.actions.declare_file(swfitmodule_name)
    ctx.actions.run_shell(
        outputs = [output_swiftmodule],
        command = "cp -f \"$1\" \"$2\"",
        arguments = [input_swiftmodule, output_swiftmodule.path],
        execution_requirements = {"no-remote-exec": "1"},
        mnemonic = "ImportSDKSwiftModule",
        progress_message = "Import SDK swift module {}".format(swfitmodule_name),
    )
    return [DefaultInfo(files = depset([output_swiftmodule]))]

sdk_swiftmodule_import = rule(
    implementation = _sdk_swiftmodule_import_impl,
    attrs = {
        "swiftmodule_path": attr.string(
            doc = """\
The absolute path to the SDK swiftmodule, e.g.,
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphoneos/prebuilt-modules/17.5/UIKit.swiftmodule.
""",
            mandatory = True,
        ),
        "module_name": attr.string(
            doc = "The swift module name",
            mandatory = True,
        ),
    },
    doc = """\
A rule imports a SDK swift module and outputs it as a file. It's required for explicit module builds.
""",
)
