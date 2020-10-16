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
        QUERY=`grep -A 2 important_output "$BAZEL_BUILD_EVENT_TEXT_FILENAME" | grep -w uri | grep ${TARGET_NAME}\" | sed "s/uri: \"file:\/\///"`
        if [[ -z $QUERY ]]; then
            echo "Unable to locate resource for framework of ${TARGET_NAME}"
            exit 1
        fi
        input_options=($(dirname "${QUERY}"))
        ;;
    com.apple.product-type.bundle.unit-test)
        input_options=("bazel-bin/$BAZEL_BIN_SUBDIR/${FULL_PRODUCT_NAME}" "bazel-bin/$BAZEL_BIN_SUBDIR/$TARGET_NAME.__internal__.__test_bundle_archive-root/$TARGET_NAME${WRAPPER_SUFFIX:-}")
        ;;
    com.apple.product-type.application)
        input_options=("bazel-bin/$BAZEL_BIN_SUBDIR/${FULL_PRODUCT_NAME}" "bazel-bin/$BAZEL_BIN_SUBDIR/${TARGET_NAME}_archive-root/Payload/$TARGET_NAME${WRAPPER_SUFFIX:-}")
        ;;
    *)
        echo "Error: Installing ${TARGET_NAME} of type ${PRODUCT_TYPE} is unsupported" >&2
        exit 1
        ;;
esac
output="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME"

mkdir -p $CONFIGURATION_TEMP_DIR/${TARGET_NAME}.build/Objects-normal/$ARCHS/
for swiftmodulefile in $BAZEL_SWIFTMODULEFILES_TO_COPY; do
  # echo $swiftmodulefile $CONFIGURATION_TEMP_DIR/${TARGET_NAME}.build/Objects-normal/$ARCHS/
  cp $swiftmodulefile $CONFIGURATION_TEMP_DIR/${TARGET_NAME}.build/Objects-normal/$ARCHS/
done

mkdir -p "$(dirname "$output")"

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
    else
        continue
    fi

    rsync \
        --recursive --chmod=u+w --delete \
        "$input" "$output" > "$BAZEL_DIAGNOSTICS_DIR"/rsync-stdout-"$DATE_SUFFIX".log 2> "$BAZEL_DIAGNOSTICS_DIR"/rsync-stderr-"$DATE_SUFFIX".log
    break
done

if [[ ! -d $output ]]; then
    echo "error: failed to find $FULL_PRODUCT_NAME in expected locations: ${input_options[*]}"
    exit 1
fi

"$BAZEL_INSTALLERS_DIR"/lldb-settings.sh > "$BAZEL_DIAGNOSTICS_DIR"/lldb-stdout-"$DATE_SUFFIX".log 2> "$BAZEL_DIAGNOSTICS_DIR"/lldb-stderr-"$DATE_SUFFIX".log

# Part of the build intermediary output will be swiftmodule files
# which XCode will use for indexing. Let's keep those.
"$BAZEL_INSTALLERS_DIR"/swiftmodules.sh > "$BAZEL_DIAGNOSTICS_DIR"/swiftmodules-stdout-"$DATE_SUFFIX".log 2> "$BAZEL_DIAGNOSTICS_DIR"/swiftmodules-stderr-"$DATE_SUFFIX".log &
"$BAZEL_INSTALLERS_DIR"/indexstores.sh > "$BAZEL_DIAGNOSTICS_DIR"/indexstores-stdout-"$DATE_SUFFIX".log 2> "$BAZEL_DIAGNOSTICS_DIR"/indexstores-stderr-"$DATE_SUFFIX".log &
