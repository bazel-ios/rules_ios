#!/usr/bin/env bash

set -euo pipefail

CLEAN=0
for ARG in "$@"; do
    case "$ARG" in
    --clean)
        CLEAN=1
        ;;
    --no-clean)
        CLEAN=0
        ;;
    *)
        echo "Unknown argument $ARG"
        exit 1
        ;;
    esac
    shift
done

echo ".xcodeproj Tests for Mac OS platform"

if [[ CLEAN = 1 ]]; then
    rm -rf tests/macos/xcodeproj/*.xcodeproj tests/macos/xcodeproj/build
    bazelisk clean
fi

bazelisk query 'kind("xcodeproj rule", tests/macos/xcodeproj/...)' | xargs -n 1 bazelisk run
bazelisk query 'attr(executable, 1, kind(genrule, tests/macos/xcodeproj/...))' | xargs -n 1 bazelisk run

./tests/macos/xcodeproj/build.sh
./tests/macos/xcodeproj/tests.sh

echo ".xcodeproj Tests for iOS platform (simulator)"

if [[ CLEAN = 1 ]]; then
    rm -rf tests/ios/xcodeproj/*.xcodeproj tests/ios/xcodeproj/build
    rm -rf tests/ios/xcodeproj/custom_output_path/*.xcodeproj tests/ios/xcodeproj/custom_output_path/build
    bazelisk clean
fi

bazelisk query 'kind("xcodeproj rule", tests/ios/xcodeproj/...)' | xargs -n 1 bazelisk run
bazelisk query 'attr(executable, 1, kind(genrule, tests/ios/xcodeproj/...))' | xargs -n 1 bazelisk run

./tests/ios/xcodeproj/pre_build_check.sh
./tests/ios/xcodeproj/build.sh simulator
./tests/ios/xcodeproj/post_build_check.sh simulator
./tests/ios/xcodeproj/tests.sh

echo ".xcodeproj Tests for iOS platform (simulator), for project generated under custom_output_path"

diff_result=$(diff -r ./tests/ios/xcodeproj/Test-LLDB-Logs-Project.xcodeproj ./tests/ios/xcodeproj/custom_output_path/Test-LLDB-Logs-Project.xcodeproj || true)
expected_diff_result=$(cat ./tests/ios/xcodeproj/fixtures/test_custom_output_path_expected_diff.txt)
if [[ "$diff_result" != "$expected_diff_result" ]]; then
    echo "The project under custom_output_path differs from the expectation"
    diff -r ./tests/ios/xcodeproj/Test-LLDB-Logs-Project.xcodeproj ./tests/ios/xcodeproj/custom_output_path/Test-LLDB-Logs-Project.xcodeproj
    exit 1
fi

echo ".xcodeproj Tests for iOS platform (device)"

if [[ CLEAN = 1 ]]; then
    rm -rf tests/ios/xcodeproj/*.xcodeproj tests/ios/xcodeproj/build
    bazelisk clean
fi

XCODE_PROJ_NAME="Test-BuildForDevice-Project"
bazelisk run //tests/ios/xcodeproj:$XCODE_PROJ_NAME --ios_multi_cpus=arm64

./tests/ios/xcodeproj/pre_build_check.sh $XCODE_PROJ_NAME
./tests/ios/xcodeproj/build.sh device $XCODE_PROJ_NAME
./tests/ios/xcodeproj/post_build_check.sh device $XCODE_PROJ_NAME

echo "Checking for .xcodeproj changes"

git diff --exit-code tests/ios/xcodeproj tests/macos/xcodeproj
STATUS=$?

# Dump these to bazel-testlogs for easier updating
find tests/ -name \*.xcodeproj \
    -exec /bin/bash -c \
    'mkdir -p bazel-testlogs/$(dirname {}) && ditto {} bazel-testlogs/$(dirname {})' \;

exit $STATUS

