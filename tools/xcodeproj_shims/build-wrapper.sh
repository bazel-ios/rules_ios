#!/bin/bash
set -euxo pipefail

BAZEL_BUILD_OPTIONS="--build_event_text_file=$BAZEL_BUILD_EVENT_TEXT_FILENAME"
BAZEL_BUILD_OPTIONS+=" --build_event_publish_all_actions"

if [ $BAZEL_EXECUTION_LOG_ENABLED -gt 0 ]; then
    BAZEL_BUILD_OPTIONS+=" --experimental_execution_log_file=$BAZEL_BUILD_EXECUTION_LOG_FILENAME"
fi

# When building for an iOS device in XCode, TARGET_DEVICE_IDENTIFIER is exported, and PLATFORM_NAME is iphoneos.
if [ -n "${TARGET_DEVICE_IDENTIFIER:-}" ] && [ "$PLATFORM_NAME" = "iphoneos" ]; then
    echo "Builds with --ios_multi_cpus=arm64 since the target is an iOS device."
    BAZEL_BUILD_OPTIONS+=" --ios_multi_cpus=arm64"
fi

$BAZEL_PATH build \
    $BAZEL_BUILD_OPTIONS \
    $1 \
    $BAZEL_RULES_IOS_OPTIONS \
    2>&1 \
    | $BAZEL_OUTPUT_PROCESSOR
