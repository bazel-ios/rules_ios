load("//rules/analysis_tests:identical_outputs_test.bzl", "identical_outputs_test")

def make_tests():
    identical_outputs_test(
        name = "test_DependencyEquivilance",
        target_under_test = ":AppWithSelectableCopts",

        # These inputs *must* be passed seperately, in order to
        # have different transitions applied by Skyframe.
        deps = [":AppWithSelectableCopts", ":SwiftLib"],
    )

    native.test_suite(
        name = "AnalysisTests",
        tests = [
            ":test_DependencyEquivilance",
        ],
    )
