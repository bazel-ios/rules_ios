load("//rules/library:xcconfig.bzl", "copts_from_xcconfig")
load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@bazel_skylib//lib:types.bzl", "types")

_Settings = provider()

def _xcconfig_test_rule_impl(ctx):
    xcconfig = {}
    xcconfig.update(ctx.attr.str)
    xcconfig.update(ctx.attr.list)
    return [
        _Settings(settings = copts_from_xcconfig(xcconfig)),
    ]

xcconfig_test_rule = rule(
    implementation = _xcconfig_test_rule_impl,
    attrs = {
        "str": attr.string_dict(),
        "list": attr.string_list_dict(),
    },
)

def _xcconfig_test_impl(ctx):
    env = analysistest.begin(ctx)

    error = ctx.attr.error
    expected = ctx.attr.expected
    if error:
        asserts.expect_failure(env, error)
    else:
        asserts.equals(env, struct(**expected), analysistest.target_under_test(env)[_Settings].settings)
    return analysistest.end(env)

xcconfig_test = analysistest.make(
    _xcconfig_test_impl,
    attrs = {
        "expected": attr.string_list_dict(),
        "error": attr.string(),
    },
)

xcconfig_failure_test = analysistest.make(
    _xcconfig_test_impl,
    expect_failure = True,
    attrs = {
        "expected": attr.string_list_dict(),
        "error": attr.string(),
    },
)

_SUITE_NAME = "xcconfig_unit_test_suite"

def assert_xcconfig(name, xcconfig, expected = None, error = None):
    name = _SUITE_NAME + "_" + name
    if expected != None and error != None:
        fail("%s: can only specify one of expected & error" % name)
    if expected == None and error == None:
        fail("%s: must specify one of expected & error" % name)

    str_dict = {}
    list_dict = {}

    for (k, v) in xcconfig.items():
        if types.is_list(v):
            list_dict[k] = v
        else:
            str_dict[k] = v

    r = xcconfig_test if expected != None else xcconfig_failure_test

    if expected != None:
        for k in ["ibtool_copts", "cc_copts", "linkopts", "momc_copts", "mapc_copts", "objc_copts", "swift_copts"]:
            if not k in expected:
                expected[k] = []

    xcconfig_test_rule(
        name = name + "_target_under_test",
        str = str_dict,
        list = list_dict,
        tags = ["manual"],
    )

    r(
        name = name,
        target_under_test = name + "_target_under_test",
        expected = expected,
        error = error,
    )
    return name

def xcconfig_unit_test_suite():
    native.test_suite(
        name = _SUITE_NAME,
        tests = [
            assert_xcconfig(
                name = "empty",
                xcconfig = {},
                expected = {},
            ),
            assert_xcconfig(
                name = "unknown_key",
                xcconfig = {"GHFJDHGHJFS": "YES"},
                expected = {},
            ),
            assert_xcconfig(
                name = "bool_as_list",
                xcconfig = {"CLANG_ENABLE_MODULES": ["YES"]},
                error = 'CLANG_ENABLE_MODULES: ["YES"] not a valid value, must be "YES" or "NO"',
            ),
            assert_xcconfig(
                name = "bool_key",
                xcconfig = {"CLANG_ENABLE_MODULES": "YES"},
                expected = {"objc_copts": ["-fmodules"]},
            ),
            assert_xcconfig(
                name = "enum_key_empty_value",
                xcconfig = {"CLANG_TRIVIAL_AUTO_VAR_INIT": "uninitialized"},
                expected = {"objc_copts": ["-ftrivial-auto-var-init=uninitialized"]},
            ),
            assert_xcconfig(
                name = "enum_key",
                xcconfig = {"CLANG_TRIVIAL_AUTO_VAR_INIT": "pattern"},
                expected = {"objc_copts": ["-ftrivial-auto-var-init=pattern"]},
            ),
            assert_xcconfig(
                name = "enum_key_unknown_value",
                xcconfig = {"CLANG_TRIVIAL_AUTO_VAR_INIT": "unknown"},
                error = 'CLANG_TRIVIAL_AUTO_VAR_INIT: "unknown" not a valid value, must be one of ["default", "uninitialized", "zero", "pattern"]',
            ),
            assert_xcconfig(
                name = "additional_linker_flags",
                xcconfig = {"SWIFT_ADDRESS_SANITIZER": "YES"},
                expected = {"swift_copts": ["-sanitize=address"], "linkopts": ["-fsanitize=address"]},
            ),
            assert_xcconfig(
                name = "otherwise_supported",
                xcconfig = {"ALTERNATE_LINKER": "foo"},
                expected = {"linkopts": ["-fuse-ld='foo'"]},
            ),
            assert_xcconfig(
                name = "empty_string_match",
                xcconfig = {"ALTERNATE_LINKER": ""},
                expected = {"linkopts": []},
            ),
            assert_xcconfig(
                name = "command_line_flag",
                xcconfig = {"SYSTEM_FRAMEWORK_SEARCH_PATHS": ["foo", "/bar"]},
                expected = {"linkopts": ["-iframework", "'foo'", "-iframework", "'/bar'"]},
            ),
            assert_xcconfig(
                name = "command_line_prefix",
                xcconfig = {"CLANG_MACRO_BACKTRACE_LIMIT": "12"},
                expected = {"objc_copts": ["-fmacro-backtrace-limit='12'"]},
            ),
            assert_xcconfig(
                name = "command_line_flag_default_bool",
                xcconfig = {"GCC_ENABLE_EXCEPTIONS": "NO"},
                expected = {"objc_copts": []},
            ),
            assert_xcconfig(
                name = "command_line_flag_non_default_bool",
                xcconfig = {"GCC_ENABLE_EXCEPTIONS": "YES"},
                expected = {"objc_copts": ["-fexceptions"]},
            ),
            assert_xcconfig(
                name = "option_with_unknown_command_line",
                xcconfig = {"OTHER_CFLAGS": ["-IFOO"]},
                expected = {},
            ),
            assert_xcconfig(
                name = "only_used_as_condition",
                xcconfig = {"APPLICATION_EXTENSION_API_ONLY": "YES"},
                expected = {"linkopts": ["-fapplication-extension", "-fapplication-extension"], "objc_copts": ["-fapplication-extension"], "swift_copts": ["-application-extension"]},
            ),
            assert_xcconfig(
                name = "option_with_inherited",
                xcconfig = {"GCC_PREPROCESSOR_DEFINITIONS": ["$(inherited)", "ABC=1"]},
                expected = {"objc_copts": ["-D'$(inherited)'", "-D'ABC=1'"]},
            ),
            assert_xcconfig(
                name = "option_with_shell_metacharacters",
                xcconfig = {"GCC_PREPROCESSOR_DEFINITIONS": ["DISPLAY_VERSION=1.0.0-beta.1", "SDK_NAME=WHY WOULD YOU ADD SPACES"]},
                expected = {"objc_copts": ["-D'DISPLAY_VERSION=1.0.0-beta.1'", "-D'SDK_NAME=WHY WOULD YOU ADD SPACES'"]},
            ),
            assert_xcconfig(
                name = "conditioned_option",  # The condition is on `$(GCC_OPTIMIZATION_LEVEL) == '0'`, which is unspecified
                xcconfig = {"LD_DONT_RUN_DEDUPLICATION": "YES"},
                expected = {},
            ),
            assert_xcconfig(
                name = "conditioned_option_enabled",
                xcconfig = {"LD_DONT_RUN_DEDUPLICATION": "YES", "GCC_OPTIMIZATION_LEVEL": "0"},
                expected = {"linkopts": ["-O'0'", "-Wl,-no_deduplicate"]},
            ),
            assert_xcconfig(
                name = "conditioned_option_disable",
                xcconfig = {"LD_DONT_RUN_DEDUPLICATION": "YES", "GCC_OPTIMIZATION_LEVEL": "1"},
                expected = {"linkopts": ["-O'1'"]},
            ),
            assert_xcconfig(
                name = "product_module_name",
                xcconfig = {"PRODUCT_MODULE_NAME": "BIG_BAD_MODULE"},
                expected = {},
            ),
            assert_xcconfig(
                name = "optimization_level_0",
                xcconfig = {"GCC_OPTIMIZATION_LEVEL": "0"},
                expected = {"linkopts": ["-O'0'", "-Wl,-no_deduplicate"]},
            ),
            assert_xcconfig(
                name = "xlinker_to_wl",
                xcconfig = {"REEXPORTED_FRAMEWORK_NAMES": ["a", "z"], "LINKER_DISPLAYS_MANGLED_NAMES": "YES"},
                expected = {"linkopts": ["-Wl,--no-demangle", "-Wl,-reexport_framework,'a'", "-Wl,-reexport_framework,'z'"]},
            ),
        ],
    )
