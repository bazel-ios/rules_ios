load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")

def load_framework_dependencies():
    http_archive(
        name = "TensorFlowLiteC",
        url = "https://dl.google.com/dl/cpdc/3895e5bf508673ae/TensorFlowLiteC-2.6.0.tar.gz",
        sha256 = "a28ce764da496830c0a145b46e5403fb486b5b6231c72337aaa8eaf3d762cc8d",
        build_file = "@//tests/ios/unit-test/test-imports-app:BUILD.TensorFlowLiteC",
        strip_prefix = "TensorFlowLiteC-2.6.0",
    )

    http_archive(
        name = "GoogleMobileAdsSDK",
        url = "https://dl.google.com/dl/cpdc/e0dda986a9f84d14/Google-Mobile-Ads-SDK-8.10.0.tar.gz",
        sha256 = "0726df5d92165912c9e60a79504a159ad9b7231dda851abede8f8792b266dba5",
        build_file = "@//tests/ios/unit-test/test-imports-app:BUILD.GoogleMobileAds",
    )

    new_git_repository(
        name = "MBProgressHUD",
        remote = "https://github.com/jdg/MBProgressHUD.git",
        build_file = "@//tests/ios/unit-test/test-imports-app:BUILD.MBProgressHUD",
        commit = "bca42b801100b2b3a4eda0ba8dd33d858c780b0d",
        shallow_since = "1578948320 +0100",
    )
