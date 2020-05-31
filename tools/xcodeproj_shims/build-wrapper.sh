#!/bin/bash
set -euxo pipefail

$BAZEL_PATH build $1 2>&1 | $BAZEL_OUTPUT_PROCESSOR
