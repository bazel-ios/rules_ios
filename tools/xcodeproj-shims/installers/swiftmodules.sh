#!/bin/bash

set -euo pipefail

# Copy Bazel build `.swiftmodule` files to `DerivedData`. This is used by Xcode
# and its indexing.

# TODO: what should BAZEL_BIN be?
# something like this:
# readonly config=macos-x86_64-min10.13-applebin_macos-darwin_x86_64-dbg
# export BAZEL_BIN=bazel-out/$config/bin
find "$BAZEL_BIN" \
     -name "*.swiftmodule" \
     -not -path "*/_swift_module_cache/*" \
     -print0 \
    | xargs -0 "$BAZEL_WORKSPACE_ROOT/tools/bazel-xcodeproj/installers/_swiftmodule.sh"