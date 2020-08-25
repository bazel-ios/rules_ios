#!/bin/bash
set -euxo pipefail

EXEC_LOG_OPTION=""
if [ $BAZEL_EXECUTION_LOG_ENABLED -gt 0 ]; then
    EXEC_LOG_OPTION="--experimental_execution_log_file=$BAZEL_BUILD_EXECUTION_LOG_FILENAME"
fi

$BAZEL_PATH build \
    $EXEC_LOG_OPTION \
    --build_event_text_file=$BAZEL_BUILD_EVENT_TEXT_FILENAME \
    --build_event_publish_all_actions $1 \
    $BAZEL_RULES_IOS_OPTIONS \
    2>&1 \
    | $BAZEL_OUTPUT_PROCESSOR
