#!/bin/bash

# Install the runnable products so that Xcode can run it. This includes `.app`s,
# `.xctest`s, and also command line binaries.

set -eux

# Delete all logfiles that are older than 7 days
find "${BAZEL_DIAGNOSTICS_DIR}" -type f -atime +7d -delete

case "${PRODUCT_TYPE}" in
com.apple.product-type.framework)
    input_options=("bazel-bin/$BAZEL_BIN_SUBDIR/${TARGET_NAME}/${FULL_PRODUCT_NAME}")
    ;;
com.apple.product-type.framework.static)
    # For static library, as the output is not under bazel-bin, we have to get it based on build event
    # Example of such entry inside build event:
    # important_output {
    #   name: ".../SomeFramework.framework/SomeFramework"
    #   uri: "file:///private/var/tmp/.../.../SomeFramework.framework/SomeFramework"
    #   path_prefix:...
    #   ...
    #  }
    # We only care about the entry ending with TARGET_NAME" so that we can get the path to its directory
    QUERY=$(grep -A 2 important_output "$BAZEL_BUILD_EVENT_TEXT_FILENAME" | grep -w uri | grep ${TARGET_NAME}\" | sed "s/uri: \"file:\/\///")
    if [[ -z $QUERY ]]; then
        # For virtual frameworks, this is disabled
        exit 0
    fi
    input_options=($(dirname "${QUERY}"))
    ;;
com.apple.product-type.bundle.unit-test)
    input_options=(
        "bazel-bin/$BAZEL_BIN_SUBDIR/${FULL_PRODUCT_NAME}"
        "bazel-bin/$BAZEL_BIN_SUBDIR/$TARGET_NAME.__internal__.__test_bundle_archive-root/$TARGET_NAME${WRAPPER_SUFFIX:-}"
        "bazel-bin/$BAZEL_BIN_SUBDIR/${BAZEL_BUILD_TARGET_LABEL#*:}.runfiles/${BAZEL_BUILD_TARGET_WORKSPACE}/${BAZEL_BIN_SUBDIR}/${FULL_PRODUCT_NAME}"
        "bazel-bin/$BAZEL_BIN_SUBDIR/${BAZEL_BUILD_TARGET_LABEL#*:}.runfiles/${BAZEL_BUILD_TARGET_WORKSPACE}/${BAZEL_BIN_SUBDIR}/$TARGET_NAME.zip"
    )
    ;;
com.apple.product-type.application)
    input_options=(
        "bazel-bin/$BAZEL_BIN_SUBDIR/${FULL_PRODUCT_NAME}"
        "bazel-bin/$BAZEL_BIN_SUBDIR/${TARGET_NAME}_archive-root/Payload/$TARGET_NAME${WRAPPER_SUFFIX:-}"
        "bazel-bin/$BAZEL_BIN_SUBDIR/${BAZEL_BUILD_TARGET_LABEL#*:}.runfiles/${BAZEL_BUILD_TARGET_WORKSPACE}/${BAZEL_BIN_SUBDIR}/${FULL_PRODUCT_NAME}"
        "bazel-bin/$BAZEL_BIN_SUBDIR/${BAZEL_BUILD_TARGET_LABEL#*:}.runfiles/${BAZEL_BUILD_TARGET_WORKSPACE}/${BAZEL_BIN_SUBDIR}/$TARGET_NAME.zip"
    )
    ;;
*)
    echo "Error: Installing ${TARGET_NAME} of type ${PRODUCT_TYPE} is unsupported" >&2
    exit 1
    ;;
esac
output="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME"

mkdir -p $OBJECT_FILE_DIR_normal/$CURRENT_ARCH/
chmod -R +w $OBJECT_FILE_DIR_normal/$CURRENT_ARCH/

for swiftmodulefile in ${BAZEL_SWIFTMODULEFILES_TO_COPY:-}; do
    if [[ -e $swiftmodulefile ]]; then
        cp $swiftmodulefile $OBJECT_FILE_DIR_normal/$CURRENT_ARCH/
    fi
done

mkdir -p "$(dirname "$output")"
copied=false

for input in "${input_options[@]}"; do
    if [[ -z $input ]] || [ $input = "." ] || [ $input = "/" ]; then
        # rsync can be a dangerous operation when it tries to copy entire root dir into the $output
        echo "Error: illegal input \"${input}\" for installing ${TARGET_NAME} of type ${PRODUCT_TYPE}" >&2
        exit 1
    fi
    if [[ -d $input ]]; then
        # Copy bundle contents, into the destination bundle.
        # This avoids self-nesting, like: Foo.app/Foo.app
        input+="/"
    elif [[ ! -f $input ]] || [[ $input != *.zip ]]; then
        continue
    fi

    if [[ $input == *.zip ]]; then
        rm -rf "$output"
        unzip -qq -d "$TARGET_BUILD_DIR" "$input"
    else
        rsync \
            --recursive --chmod=u+w --delete --copy-links \
            "$input" "$output" >"$BAZEL_DIAGNOSTICS_DIR"/rsync-stdout-"$DATE_SUFFIX".log 2>"$BAZEL_DIAGNOSTICS_DIR"/rsync-stderr-"$DATE_SUFFIX".log
    fi

    if [[ -n "${SWIFT_OBJC_INTERFACE_HEADER_NAME:-}" ]]; then
        cp -f "$input/Headers/$SWIFT_OBJC_INTERFACE_HEADER_NAME" "$OBJECT_FILE_DIR_normal/$CURRENT_ARCH/"
    fi

    copied=true
    break
done

if [[ ! -d "$output" ]] || [[ "$copied" = 'false' ]]; then
    echo "error: failed to find $FULL_PRODUCT_NAME in expected locations: ${input_options[*]}"
    exit 1
fi

"$BAZEL_INSTALLERS_DIR"/lldb-settings.sh >"$BAZEL_DIAGNOSTICS_DIR"/lldb-stdout-"$DATE_SUFFIX".log 2>"$BAZEL_DIAGNOSTICS_DIR"/lldb-stderr-"$DATE_SUFFIX".log

# Part of the build intermediary output will be swiftmodule files
# which XCode will use for indexing. Let's keep those.
"$BAZEL_INSTALLERS_DIR"/swiftmodules.sh >"$BAZEL_DIAGNOSTICS_DIR"/swiftmodules-stdout-"$DATE_SUFFIX".log 2>"$BAZEL_DIAGNOSTICS_DIR"/swiftmodules-stderr-"$DATE_SUFFIX".log &
"$BAZEL_INSTALLERS_DIR"/indexstores.sh >"$BAZEL_DIAGNOSTICS_DIR"/indexstores-stdout-"$DATE_SUFFIX".log 2>"$BAZEL_DIAGNOSTICS_DIR"/indexstores-stderr-"$DATE_SUFFIX".log &
