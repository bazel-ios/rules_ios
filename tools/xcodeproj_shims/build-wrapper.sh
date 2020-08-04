#!/bin/bash
set -euxo pipefail

$BAZEL_PATH build --experimental_execution_log_file=$BAZEL_BUILD_EXECUTION_LOG_FILENAME --build_event_text_file=$BAZEL_BUILD_EVENT_TEXT_FILENAME --build_event_publish_all_actions $1 --@build_bazel_rules_ios//rules:local_debug_options_enabled 2>&1 | $BAZEL_OUTPUT_PROCESSOR
