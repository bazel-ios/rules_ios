#!/bin/bash

set -euo pipefail


# Bazel uses `-debug-prefix-map` to strip the bazel build directory from the
# paths embedded in debug info. This means the debug info contains _project
# relative_ paths instead of Bazel absolute paths.
#
# However, Xcode sets breakpoints via _project absolute_ paths, which are not
# the paths in the debug info. This lldb setting ensures that _project relative_
# paths are remapped to _project absolute_ paths.
#
# NOTE: In order to use this, add this line to `~/.lldbinit`:
#
#     command source ~/.lldbinit-source-map
cat <<-END > ~/.lldbinit-source-map
settings set target.source-map ./external/ "$BAZEL_WORKSPACE_ROOT/bazel-$(basename "$BAZEL_WORKSPACE_ROOT")/external"
settings append target.source-map ./ "$BAZEL_WORKSPACE_ROOT/"
settings set target.sdk-path $SDKROOT
settings set target.swift-framework-search-paths $FRAMEWORK_SEARCH_PATHS
END
