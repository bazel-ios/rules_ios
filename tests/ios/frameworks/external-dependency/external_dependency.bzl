load("//rules:repositories.bzl", "github_repo")

def load_external_test_dependency():
    github_repo(
        name = "com_github_apple_swiftcollections",
        build_file = "@//tests/ios/frameworks/external-dependency:BUILD.com_github_apple_swiftcollections",
        project = "apple",
        ref = "0.0.3",
        repo = "swift-collections",
        sha256 = "e6f36a1f9bb163437b4e9bc8da641a6129f16af7799eb8418c4a35749ceb1ef7",
    )
