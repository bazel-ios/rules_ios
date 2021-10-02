load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def load_framework_dependencies():
    http_archive(
        name = "TensorFlowLiteC",
        url = "https://dl.google.com/dl/cpdc/3895e5bf508673ae/TensorFlowLiteC-2.6.0.tar.gz",
        sha256 = "a28ce764da496830c0a145b46e5403fb486b5b6231c72337aaa8eaf3d762cc8d",
        build_file = "@//tests/ios/unit-test/test-imports-app:BUILD.TensorFlowLiteC",
        strip_prefix = "TensorFlowLiteC-2.6.0",
    )
