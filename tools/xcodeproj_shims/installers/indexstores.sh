#!/bin/bash

set -euo pipefail

# See `_indexstore.sh` for full details.

# Make sure add these to bazel build target copts for objective-c
find "$BAZEL_WORKSPACE_ROOT/bazel-out"/*/bin/ \
     -type d \
     -name "*.indexstore" \
     -print0 \
    | xargs -0 "$BAZEL_INSTALLERS_DIR/_indexstore.sh"

echo "Finish remapping index files"