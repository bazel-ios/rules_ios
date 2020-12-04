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

bazelisk query 'kind(xcodeproj, tests/macos/xcodeproj/...)' | xargs -n 1 bazelisk run --@build_bazel_rules_ios//rules:local_debug_options_enabled
bazelisk query 'attr(executable, 1, kind(genrule, tests/macos/xcodeproj/...))' | xargs -n 1 bazelisk run
git diff --exit-code tests/macos/xcodeproj

./tests/macos/xcodeproj/build.sh
./tests/macos/xcodeproj/tests.sh

echo ".xcodeproj Tests for iOS platform"

if [[ CLEAN = 1 ]]; then
    rm -rf tests/ios/xcodeproj/*.xcodeproj tests/ios/xcodeproj/build
    bazelisk clean
fi

bazelisk query 'kind(xcodeproj, tests/ios/xcodeproj/...)' | xargs -n 1 bazelisk run --@build_bazel_rules_ios//rules:local_debug_options_enabled
bazelisk query 'attr(executable, 1, kind(genrule, tests/ios/xcodeproj/...))' | xargs -n 1 bazelisk run
git diff --exit-code tests/ios/xcodeproj

./tests/ios/xcodeproj/pre_build_check.sh
./tests/ios/xcodeproj/build.sh
./tests/ios/xcodeproj/post_build_check.sh
./tests/ios/xcodeproj/tests.sh
