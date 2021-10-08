load("//rules/analysis_tests:transitive_header_test.bzl", "transitive_header_test")

def make_tests():
    transitive_header_test(
        name = "test_SomeFramework_SwiftCompilationHeaders",
        target_under_test = ":SomeFramework_swift",
        deps = ["//tests/ios/unit-test/test-imports-app/frameworks/Basic"],
    )

    transitive_header_test(
        name = "test_App_SwiftCompilationHeaders",
        target_under_test = ":TestImports-App_swift",
        deps = ["//tests/ios/unit-test/test-imports-app/frameworks/Basic", "@TensorFlowLiteC//:TensorFlowLiteC"],
    )

    native.test_suite(
        name = "AnalysisTests",
        tests = [
            ":test_App_SwiftCompilationHeaders",
            ":test_SomeFramework_SwiftCompilationHeaders",
        ],
    )
