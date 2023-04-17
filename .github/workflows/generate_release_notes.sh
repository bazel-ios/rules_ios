#!/bin/bash

set -exuo pipefail

# This script generates release notes for a release.
# It uses the new tag and archive to generate a workspace snippet.
# It is primarily used by the `create_release.yml` workflow.
# Args:
#  - The first argument is the new version number.

readonly new_version=$1
readonly release_archive="rules_ios.$new_version.tar.gz"

sha=$(shasum -a 256 "$release_archive" | cut -d " " -f1)

cat <<EOF
### Workspace Snippet

\`\`\`bzl
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "build_bazel_rules_ios",
    sha256 = "$sha",
    url = "https://github.com/bazelbuild/rules_ios/releases/download/$new_version/rules_ios.$new_version.tar.gz",
)

load(
    "@build_bazel_rules_ios//rules:repositories.bzl",
    "rules_ios_dependencies"
)

rules_ios_dependencies()

load(
    "@build_bazel_rules_apple//apple:repositories.bzl",
    "apple_rules_dependencies",
)

apple_rules_dependencies()

load(
    "@build_bazel_rules_swift//swift:repositories.bzl",
    "swift_rules_dependencies",
)

swift_rules_dependencies()

load(
    "@build_bazel_apple_support//lib:repositories.bzl",
    "apple_support_dependencies",
)

apple_support_dependencies()

load(
    "@com_google_protobuf//:protobuf_deps.bzl",
    "protobuf_deps",
)

protobuf_deps()
\`\`\`
EOF
