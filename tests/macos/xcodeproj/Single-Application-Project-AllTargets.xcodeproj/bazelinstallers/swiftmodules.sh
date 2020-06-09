#!/bin/bash

set -euo pipefail

# Copy Bazel build `.swiftmodule` files to `DerivedData`. This is used by Xcode
# and its indexing.
find "$BAZEL_WORKSPACE_ROOT/bazel-out"/*/bin/ \
    -name "*.swiftmodule" \
     -not -path "*/_swift_module_cache/*" \
     -print0 \
    | xargs -0 "$BAZEL_INSTALLERS_DIR/_swiftmodule.sh"
