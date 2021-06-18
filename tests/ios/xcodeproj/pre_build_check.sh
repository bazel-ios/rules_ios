set -eu

cd $(dirname $0)
# XCODE_PROJ is used to find the '.xcodeproj' files, by default its value is '*'
# but one can pass a filename without the extension to this script to
# run all the logic in this script only for that one project
XCODE_PROJ_GLOB=${1:-*}

export HSP=$(grep "HEADER_SEARCH_PATHS" $XCODE_PROJ_GLOB.xcodeproj/project.pbxproj | grep -o "bazel-out\S*\.hmap")
echo "Ensure hmap files do not exist (remove if they do)"
for path in ${HSP}; do
    FULL_PATH="../../../$path"
    if [ -f $FULL_PATH ]; then
        rm -f $FULL_PATH
        echo "Removed file at $FULL_PATH"
    fi
done

export FSP=$(grep "FRAMEWORK_SEARCH_PATHS" $XCODE_PROJ_GLOB.xcodeproj/project.pbxproj | grep -o "bazel-out[^ \]*")
echo "Ensure framework search paths do not exist"
for path in ${FSP}; do
    FULL_PATH="../../../$path"
    if [ -f $FULL_PATH ]; then
        rm -rf $FULL_PATH
        echo "Removed file at $FULL_PATH"
    fi
done

# Xcodebuild will place built products under the "build" directory next to the project file.
# Later we will confirm that there are no empty swiftmodules files under the build products directory
rm -rf build
