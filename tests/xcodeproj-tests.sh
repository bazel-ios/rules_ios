#!/usr/bin/env bash

set -euo pipefail

test_macos() {
    echo ".xcodeproj Tests for Mac OS platform"
    bazelisk query 'kind("xcodeproj rule", tests/macos/xcodeproj/...)' | xargs -n 1 bazelisk run
    bazelisk query 'attr(executable, 1, kind(genrule, tests/macos/xcodeproj/...))' | xargs -n 1 bazelisk run
    ./tests/macos/xcodeproj/build.sh
    ./tests/macos/xcodeproj/tests.sh
}

test_simulator() {
    echo ".xcodeproj Tests for iOS platform (simulator)"
    bazelisk query 'kind("xcodeproj rule", tests/ios/xcodeproj/...)' | xargs -n 1 bazelisk run
    bazelisk query 'attr(executable, 1, kind(genrule, tests/ios/xcodeproj/...))' | xargs -n 1 bazelisk run
    ./tests/ios/xcodeproj/pre_build_check.sh
    ./tests/ios/xcodeproj/build.sh simulator
    ./tests/ios/xcodeproj/post_build_check.sh simulator
    ./tests/ios/xcodeproj/tests.sh
}

test_custom_output() {
    echo ".xcodeproj Tests for iOS platform (simulator), for project generated under custom_output_path"

    diff_result=$(diff -r ./tests/ios/xcodeproj/Test-LLDB-Logs-Project.xcodeproj ./tests/ios/xcodeproj/custom_output_path/Test-LLDB-Logs-Project.xcodeproj || true)
    expected_diff_result=$(cat ./tests/ios/xcodeproj/fixtures/test_custom_output_path_expected_diff.txt)
    if [[ "$diff_result" != "$expected_diff_result" ]]; then
        echo "The project under custom_output_path differs from the expectation"
        diff -r ./tests/ios/xcodeproj/Test-LLDB-Logs-Project.xcodeproj ./tests/ios/xcodeproj/custom_output_path/Test-LLDB-Logs-Project.xcodeproj
        exit 1
    fi
}

test_build_for_device() {
    XCODE_PROJ_NAME="Test-BuildForDevice-Project"
    bazelisk run //tests/ios/xcodeproj:$XCODE_PROJ_NAME --ios_multi_cpus=arm64

    ./tests/ios/xcodeproj/pre_build_check.sh $XCODE_PROJ_NAME
    ./tests/ios/xcodeproj/build.sh device $XCODE_PROJ_NAME
    ./tests/ios/xcodeproj/post_build_check.sh device $XCODE_PROJ_NAME
}

verify() {
    echo "Checking for .xcodeproj changes"
    git diff --exit-code tests/ios/xcodeproj tests/macos/xcodeproj
    STATUS=$?

    # Dump these to bazel-testlogs for easier updating
    find tests/ -name \*.xcodeproj \
        -exec /bin/bash -c \
        'mkdir -p bazel-testlogs/$(dirname {}) && ditto {} bazel-testlogs/$(dirname {})' \;
    exit $STATUS
}

test_main() {
    test_macos
    test_simulator
    test_custom_output
    test_build_for_device
    verify
}

clean_projects() {
    # The xcframeworks directory contains actual fixtures - have a better
    # convention longer term
    find \
	tests/ios/xcodeproj \
	tests/macos/xcodeproj \
	-type d -name \*.xcodeproj  \
	-exec rm -rf {} \; 2> /dev/null
}

update() {
    echo "Updating projects."
    bazelisk query 'kind("xcodeproj rule", tests/macos/xcodeproj/...)' | xargs -n 1 bazelisk run
    bazelisk query 'attr(executable, 1, kind(genrule, tests/macos/xcodeproj/...))' | xargs -n 1 bazelisk run
    bazelisk query 'kind("xcodeproj rule", tests/ios/xcodeproj/...)' | xargs -n 1 bazelisk run
    bazelisk query 'attr(executable, 1, kind(genrule, tests/ios/xcodeproj/...))' | xargs -n 1 bazelisk run
    bazelisk run //tests/ios/xcodeproj:Test-BuildForDevice-Project --ios_multi_cpus=arm64
}

if [[ "$(arch)" == "arm"* ]]; then
    echo -e "warning: rerun where Bazel is an x64_64 bazel:\narch -arch x86_64 /bin/bash -l -c \"$0 ${@}\""

    # This should work - rules_ios has been proven to work in this. If you
    # don't have the right version of Bazelisk then install it.
    #
    # This is tested on bash Montery M1 Max to work. A lot of these tools will
    # not work when spawned under rosetta without a login shell
    arch -arch x86_64 $SHELL -l -c "$0 ${@}"
    exit $?
fi


for ARG in "$@"; do
    case "$ARG" in
    --clean)
        clean_projects
	exit $?
        ;;
    --run)
        test_main
	exit $?
        ;;
    --update)
        update
	exit $?
        ;;
    *)
	shift
    esac
done

echo "usage: $0 [--clean|--run|--update]"
exit 1
