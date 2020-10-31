set -eu

cd $(dirname $0)

export HSP=`grep "HEADER_SEARCH_PATHS" *.xcodeproj/project.pbxproj | grep -o  "bazel-out\S*\.hmap"`
echo "Ensure hmap files do not exist (remove if they do)"
for path in ${HSP}; do
    FULL_PATH="../../../$path"
    if [ -f $FULL_PATH ]; then
        rm $FULL_PATH;
        echo "Removed file at $FULL_PATH";
    fi
done

export FSP=`grep "FRAMEWORK_SEARCH_PATHS" *.xcodeproj/project.pbxproj | grep -o "bazel-out[^ \\]*"`
echo "Ensure framework search paths do not exist"
for path in ${FSP}; do
    FULL_PATH="../../../$path"
    if [ -f $FULL_PATH ]; then
        rm -rf $FULL_PATH;
        echo "Removed file at $FULL_PATH";
    fi
done

# Xcodebuild will place built products under the "build" directory next to the project file.
# Later we will confirm that there are no empty swiftmodules files under the build products directory
rm -rf build