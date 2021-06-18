#!/bin/bash
set -euxo pipefail

declare -a BAZEL_BUILD_OPTIONS=(
    "--build_event_text_file=$BAZEL_BUILD_EVENT_TEXT_FILENAME"
    "--build_event_publish_all_actions"
    "--nobuild_event_text_file_path_conversion"
    "--use_top_level_targets_for_symlinks"
)

# HACK: only needed until we can presume https://github.com/bazelbuild/bazel/pull/12563
xcode_version="$($BAZEL_PATH query 'attr("name", "version.+_'"${XCODE_PRODUCT_BUILD_VERSION}"'", kind(xcode_version, @local_config_xcode//:*))')"
if [ -n "$xcode_version" ]; then
    xcode_version="$(echo "${xcode_version#*:version*}" | tr _ .)"
    BAZEL_BUILD_OPTIONS+=("--xcode_version=$xcode_version")
else
    echo "warning: Falling back on default xcode for execution, bazel did not find $XCODE_PRODUCT_BUILD_VERSION in @local_config_xcode"
fi

if [ $BAZEL_EXECUTION_LOG_ENABLED -gt 0 ]; then
    BAZEL_BUILD_OPTIONS+=("--experimental_execution_log_file=$BAZEL_BUILD_EXECUTION_LOG_FILENAME")
fi

if [ $BAZEL_PROFILE_ENABLED -gt 0 ]; then
    BAZEL_BUILD_OPTIONS+=("--profile=$BAZEL_PROFILE_FILENAME")
fi

# When building for an iOS device in XCode, TARGET_DEVICE_IDENTIFIER is exported, and PLATFORM_NAME is iphoneos.
if [ -n "${TARGET_DEVICE_IDENTIFIER:-}" ] && [ "$PLATFORM_NAME" = "iphoneos" ]; then
    echo "Builds with --ios_multi_cpus=arm64 since the target is an iOS device."
    BAZEL_BUILD_OPTIONS+=("--ios_multi_cpus=arm64")
fi

# If bazel configs (from .bazelrc file) were specificed and the current
# $CONFIGURATION is one of them append '--config=$CONFIGURATION'
if [ ! -z ${BAZEL_CONFIGS+x} ]; then
    if [[ " ${BAZEL_CONFIGS[@]} " =~ "${CONFIGURATION}" ]]; then
        BAZEL_BUILD_OPTIONS+=("--config=$CONFIGURATION")
    fi
fi
# Additional `bazel build` options that can be set in the
# 'additional_prebuild_script' attribute if the 'xcodeproj' rule
#
# Particularly useful for integration tests where one might want
# to generate an Xcode project that builds with specific additional parameters to simulate a use case
if [ ! -z ${BAZEL_ADDITIONAL_BAZEL_BUILD_OPTIONS+x} ]; then
    BAZEL_BUILD_OPTIONS+=($BAZEL_ADDITIONAL_BAZEL_BUILD_OPTIONS)
fi

$BAZEL_PATH build \
    "${BAZEL_BUILD_OPTIONS[@]}" \
    $1 \
    2>&1 |
    $BAZEL_OUTPUT_PROCESSOR
