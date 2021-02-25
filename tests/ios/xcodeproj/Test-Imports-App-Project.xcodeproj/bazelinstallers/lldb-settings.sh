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
# The platform settings one points the current working directory (cwd) to workspace root.
# This is needed for features relying on lldb remote debugging, such as `oso_prefix_is_pwd`.
cat > $BAZEL_LLDB_INIT_FILE <<-END
platform settings -w "$BAZEL_WORKSPACE_ROOT/"

settings set target.source-map ./ "$BAZEL_WORKSPACE_ROOT/"
settings set target.sdk-path $SDKROOT
settings set target.swift-framework-search-paths $FRAMEWORK_SEARCH_PATHS
END

# Holds all swift-extra-clang-flags
LLDB_SWIFT_EXTRA_CLANG_FLAGS=()
# Append extra clang flags if set
if [[ -n ${BAZEL_LLDB_SWIFT_EXTRA_CLANG_FLAGS:-} ]]
then
  LLDB_SWIFT_EXTRA_CLANG_FLAGS+=($BAZEL_LLDB_SWIFT_EXTRA_CLANG_FLAGS)
fi
# Append the file 'BAZEL_LLDB_FRAMEWORK_SEARCH_PATHS_FILE' exists
# it memans that there are framework search paths that LLDB should
# be aware of so append the contents of that file
#
# Look for this logic in 'rules/xcodeproj.bzl'
if [[ -n "$BAZEL_LLDB_FRAMEWORK_SEARCH_PATHS_FILE" ]]
then
  # All framework search paths from file
  FSPS="$(cat $BAZEL_WORKSPACE_ROOT/$BAZEL_LLDB_FRAMEWORK_SEARCH_PATHS_FILE)"
  # Xcode won't resolve these paths for us since we're
  # passing it directly from file to file
  #
  # Manually solving 'BAZEL_WORKSPACE_ROOT' and 'PLATFORM_DIR' for now 
  # until it's possible to pass bigger build settings to Xcode
  #
  # For context see: https://github.com/bazel-ios/rules_ios/pull/216
  FSPS_WITH_ROOT_RESOLVED=${FSPS//"\$BAZEL_WORKSPACE_ROOT"/$BAZEL_WORKSPACE_ROOT}
  FSPS_WITH_ROOT_RESOLVED=${FSPS_WITH_ROOT_RESOLVED//"\$(PLATFORM_DIR)"/$PLATFORM_DIR}
  LLDB_SWIFT_EXTRA_CLANG_FLAGS+=($FSPS_WITH_ROOT_RESOLVED)
fi
# Set all swift-extra-clang-flags if 'LLDB_SWIFT_EXTRA_CLANG_FLAGS'
# is not empty
if [[ ${#LLDB_SWIFT_EXTRA_CLANG_FLAGS[@]} -ne 0 ]]
then
  cat >> $BAZEL_LLDB_INIT_FILE <<-END
settings set -- target.swift-extra-clang-flags ${LLDB_SWIFT_EXTRA_CLANG_FLAGS[@]}
END
fi

BAZEL_EXTERNAL_DIRNAME="$BAZEL_WORKSPACE_ROOT/bazel-$(basename "$BAZEL_WORKSPACE_ROOT")/external"
if [ -d "$BAZEL_EXTERNAL_DIRNAME" ]
then
  cat >> $BAZEL_LLDB_INIT_FILE <<-END
settings append target.source-map ./external/ "$BAZEL_EXTERNAL_DIRNAME"
END
fi
