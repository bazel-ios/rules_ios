#!/bin/bash

# Install the runnable products so that Xcode can run it. This includes `.app`s,
# `.xctest`s, and also command line binaries.

# TODO: Lyft uses this script, because Xcode calls `ditto` on the `.swiftmodule`/`.swiftdoc` files of the top-level
# target.
# "$SRCROOT"/bazel/installers/xcode-artifacts.sh

set -eux


diagnostics_dir="$TARGET_BUILD_DIR/../../../bazel-xcode-diagnostics/"
mkdir -p $diagnostics_dir

# Delete all logfiles that are older than 7 days
find $diagnostics_dir -type f -atime +7d -delete
date_suffix="$(date +%Y%m%d.%H%M%S%L)"

case ${PRODUCT_TYPE} in
    com.apple.product-type.framework)
        input="bazel-bin/$BAZEL_BIN_SUBDIR/${TARGET_NAME}/${FULL_PRODUCT_NAME}"
        ;;
    com.apple.product-type.bundle.unit-test)
        input="bazel-bin/$BAZEL_BIN_SUBDIR/$TARGET_NAME.__internal__.__test_bundle_archive-root/$TARGET_NAME${WRAPPER_SUFFIX:-}"
        ;;
    com.apple.product-type.application)
        input="bazel-bin/$BAZEL_BIN_SUBDIR/${TARGET_NAME}_archive-root/Payload/$TARGET_NAME${WRAPPER_SUFFIX:-}"
        ;;
    *)
        echo "Error: Installing ${TARGET_NAME} of type ${PRODUCT_TYPE} is unsupported" >&2
        exit 1
        ;;
esac
output="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME"

mkdir -p "$(dirname "$output")"

if [[ -d $input ]]; then
    # Copy bundle contents, into the destination bundle.
    # This avoids self-nesting, like: Foo.app/Foo.app
    input+="/"
fi


rsync \
    --recursive --chmod=u+w --delete \
    "$input" "$output" > $diagnostics_dir/rsync-stdout-$date_suffix.log 2> $diagnostics_dir/rsync-stderr-$date_suffix.log


# Part of the build intermediary output will be swiftmodule files
# which XCode will use for indexing. Let's keep those.
$BAZEL_INSTALLERS_DIR/swiftmodules.sh > $diagnostics_dir/swiftmodules-stdout-$date_suffix.log 2> $diagnostics_dir/swiftmodules-stderr-$date_suffix.log &
$BAZEL_INSTALLERS_DIR/indexstores.sh > $diagnostics_dir/indexstores-stdout-$date_suffix.log 2> $diagnostics_dir/indexstores-stderr-$date_suffix.log &
$BAZEL_INSTALLERS_DIR/lldb-settings.sh  > $diagnostics_dir/lldb-stdout-$date_suffix.log 2> $diagnostics_dir/lldb-stderr-$date_suffix.log &


