#!/bin/bash

set -euo pipefail

# Import Bazel built indexstores into Xcode. See https://github.com/lyft/index-import
#
# This makes use of a number of Xcode's provided environment variables. These
# file remappings are not specific to this project, the apply to all projects
# built with Bazel and rules_swift.

# Example: /private/var/tmp/_bazel_<username>/<hash>/execroot/<workspacename>
readonly bazel_root="^/private/var/tmp/_bazel_.+?/.+?/execroot/[^/]+"
readonly bazel_bin="^(?:$bazel_root/)?bazel-out/.+?/bin"

# Object file paths are fundamental to how Xcode loads from the indexstore. If
# the `OutputFile` does not match what Xcode looks for, then those parts of the
# indexstore will not be found and used.
readonly bazel_swift_object="$bazel_bin/.*/(.+?)(?:_swift)?_objs/.*/(.+?)[.]swift[.]o$"
readonly bazel_objc_object="$bazel_bin/.*/_objs/(?:arc/|non_arc/)?(.+?)-(?:objc|cpp)/(.+?)[.]o$"
readonly xcode_object="$CONFIGURATION_TEMP_DIR/\$1.build/Objects-normal/$ARCHS/\$2.o"

# Bazel built `.swiftmodule` files are copied to `DerivedData`. Since modules
# are referenced by indexstores, their paths are remapped.
readonly bazel_module="$bazel_bin/.*/(.+?)[.]swiftmodule$"
readonly xcode_module="$BUILT_PRODUCTS_DIR/\$1.swiftmodule/$ARCHS.swiftmodule"

# External dependencies are available via the `bazel-<workspacename>` symlink.
# This remapping, in combination with `xcode-index-preferences.json`, enables
# index features for external dependencies, such as jump-to-definition.
readonly bazel_external="$bazel_root/external"
readonly xcode_external="$BAZEL_WORKSPACE_ROOT/bazel-$(basename "$SRCROOT")/external"


$BAZEL_INSTALLERS_DIR/index-import \
    -remap "$bazel_module=$xcode_module" \
    -remap "$bazel_swift_object=$xcode_object" \
    -remap "$bazel_objc_object=$xcode_object" \
    -remap "$bazel_external=$xcode_external" \
    -remap "$bazel_root=$BAZEL_WORKSPACE_ROOT" \
    -remap "^([^//])=$BAZEL_WORKSPACE_ROOT/\$1" \
    "$@" \
    "$BUILD_DIR"/../../Index/DataStore
