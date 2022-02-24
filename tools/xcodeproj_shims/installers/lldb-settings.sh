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
cat > "$BAZEL_LLDB_INIT_FILE" <<-END
platform settings -w "$BAZEL_WORKSPACE_ROOT/"

settings set target.source-map ./ "$BAZEL_WORKSPACE_ROOT/"
settings set target.sdk-path $SDKROOT
settings set target.swift-framework-search-paths $FRAMEWORK_SEARCH_PATHS
END

if [ -n "${BAZEL_ADDITIONAL_LLDB_SETTINGS+x}" ]; then
  cat >> "$BAZEL_LLDB_INIT_FILE" <<-END
${BAZEL_ADDITIONAL_LLDB_SETTINGS}
END
fi

# Holds all swift-extra-clang-flags
LLDB_SWIFT_EXTRA_CLANG_FLAGS=()
# Append extra clang flags if set
if [[ -n ${BAZEL_LLDB_SWIFT_EXTRA_CLANG_FLAGS:-} ]]
then
  LLDB_SWIFT_EXTRA_CLANG_FLAGS+=("$BAZEL_LLDB_SWIFT_EXTRA_CLANG_FLAGS")
fi
# Pass all 'FRAMEWORK_SEARCH_PATHS' to lldb
# so debugging swift files in mixed swift/objc
# projects work
#
# See original approach to fix this for more details
# https://github.com/bazel-ios/rules_ios/pull/213
for fsp in $FRAMEWORK_SEARCH_PATHS; do
  # We don't want LLDB so look for things under DerivedData
  # given the fact that all relevant paths are being created
  # under 'bazel-out'
  if [[ "$fsp" != *"$BUILT_PRODUCTS_DIR"* ]]
  then
    # Note that these paths will come quoted
    # and with the Xcode env vars already resolved
    # so we can just pass them without any modification
    LLDB_SWIFT_EXTRA_CLANG_FLAGS+=(" -F$fsp")
  fi
done
# So LLDB is aware of all headers that are not visible
# from $FRAMEWORK_SEARCH_PATHS above
#
# Fox example, test hosts that depend on objc -> swift
# bridging headers that only exists in .hmap files
for hdr in $HEADER_SEARCH_PATHS; do
  # We don't want LLDB so look for things under DerivedData
  # given the fact that all relevant paths are being created
  # under 'bazel-out'
  if [[ "$hdr" != *"$BUILT_PRODUCTS_DIR"* ]]
  then
    # Note that these paths will come quoted
    # and with the Xcode env vars already resolved
    # so we can just pass them without any modification
    LLDB_SWIFT_EXTRA_CLANG_FLAGS+=(" -I$hdr")
  fi
done
# If on the `Debug` config append
# the `-D DEBUG` flag so the debugger
# works properly
#
# Note that this is connected to the available
# build configurations and at this time we're
# creating `Debug` and `Release` by default
#
# Once we move away from that approach and start
# fully mirroring the configs in the `.bazelrc`
# file this needs to be changed and added to all
# configs of type `debug`
#
# See: https://github.com/bazel-ios/rules_ios/blob/master/rules/xcodeproj.bzl#L828-L837
if [[ "$CONFIGURATION" = "Debug" ]]
then
  LLDB_SWIFT_EXTRA_CLANG_FLAGS+=(" -D DEBUG")
fi
# Set all swift-extra-clang-flags if 'LLDB_SWIFT_EXTRA_CLANG_FLAGS'
# is not empty
if [[ ${#LLDB_SWIFT_EXTRA_CLANG_FLAGS[@]} -ne 0 ]]
then
  cat >> "$BAZEL_LLDB_INIT_FILE" <<-END
settings set -- target.swift-extra-clang-flags ${LLDB_SWIFT_EXTRA_CLANG_FLAGS[@]}
END
fi

BAZEL_EXTERNAL_DIRNAME="$BAZEL_WORKSPACE_ROOT/bazel-$(basename "$BAZEL_WORKSPACE_ROOT")/external"
if [ -d "$BAZEL_EXTERNAL_DIRNAME" ]
then
  cat >> "$BAZEL_LLDB_INIT_FILE" <<-END
settings append target.source-map ./external/ "$BAZEL_EXTERNAL_DIRNAME"
END
fi
