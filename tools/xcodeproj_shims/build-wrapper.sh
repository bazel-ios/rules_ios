#!/bin/bash
set -euxo pipefail

$BAZEL_PATH build --build_event_text_file=$BAZEL_BUILD_EVENT_TEXT_FILENAME --build_event_publish_all_actions $1 2>&1 | $BAZEL_OUTPUT_PROCESSOR
