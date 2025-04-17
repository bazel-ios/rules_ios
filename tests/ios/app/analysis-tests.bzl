load("//rules/analysis_tests:default_outputs_test.bzl", "default_outputs_test")
load("//rules/analysis_tests:identical_outputs_test.bzl", "identical_outputs_test")

def make_tests():
    identical_outputs_test(
        name = "test_DependencyEquivilance",
        target_under_test = ":AppWithSelectableCopts",

        # These inputs *must* be passed seperately, in order to
        # have different transitions applied by Skyframe.
        deps = [":AppWithSelectableCopts", ":SwiftLib"],
    )

    default_outputs_test(
        name = "test_FWOutputs",
        target_under_test = ":FW",
        expected_output_file_paths = [
            "FW/FW.framework/FW",
            "FW/FW.framework/Headers/FW.h",
            "FW/FW.framework/Headers/FW-umbrella.h",
            "FW/FW.framework/PrivateHeaders/FW_Private.h",
            "FW/FW.framework/Modules/module.modulemap",
        ],
    )

    native.test_suite(
        name = "AnalysisTests",
        tests = [
            ":test_DependencyEquivilance",
        ],
    )
