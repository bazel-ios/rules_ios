set -eu
# DESTINATION_TYPE should be one of 'simulator' or 'device'
# this is used to pick the correct sdk when invoking 'xcodebuild' in this script
DESTINATION_TYPE=${1:-simulator}
if [ $DESTINATION_TYPE != "simulator" ] && [ $DESTINATION_TYPE != "device" ]; then
    echo "Unknown DESTINATION_TYPE: $DESTINATION_TYPE"
    exit 1
fi
# XCODE_PROJ is used to find the '.xcodeproj' files, by default its value is '*'
# but one can pass a filename without the extension to this script to
# run all the logic in this script only for that one project
XCODE_PROJ_GLOB=${2:-*}

cd $(dirname $0)

binary=$(ls ../../../bazel-out/*/bin/tests/ios/unit-test/test-imports-app/TestImports-App_archive-root/Payload/TestImports-App.app/TestImports-App)

# The linked binary should include ASTs for the transitive dependency as well
export NUM_LINKED_ASTS=$(dsymutil -s "$binary" | grep -c N_AST)
[[ $NUM_LINKED_ASTS == 2 ]]

export HSP=$(grep "HEADER_SEARCH_PATHS" $XCODE_PROJ_GLOB.xcodeproj/project.pbxproj | grep -o "bazel-out\S*\.hmap")
echo "Make sure hmap files exist after build"
for path in ${HSP}; do
    FULL_PATH="../../../$path"
    if [ ! -f $FULL_PATH ]; then
        echo "File at $FULL_PATH not found!"
        exit 1
    fi
done

export FSP=$(grep -w "FRAMEWORK_SEARCH_PATHS" $XCODE_PROJ_GLOB.xcodeproj/project.pbxproj | grep -o "bazel-out[^ \]*")
echo "Make sure framework search paths exist after build"
for path in ${FSP}; do
    FULL_PATH="../../../$path"
    if [ ! -e $FULL_PATH ]; then
        echo "File at $FULL_PATH not found!"
        exit 1
    fi
done

export EMPTY_SWIFTMODULE_FILES=`find build/Debug-iphoneos -name *".swiftmodule" -size 0`
for esf in ${EMPTY_SWIFTMODULE_FILES}; do
	echo "Swiftmodule in build products dir at $esf is empty!";
	exit 1;
done

# LLDB tests
# For each generated '.xcodeproj' check if the list of 'HEADER_SEARCH_PATHS' and
# 'FRAMEWORK_SEARCH_PATHS' are present in the generated LLDB configuration file for each target
#
# If 'target.swift-extra-clang-flags' does not contain all those paths debugging '.swift' files
# that depends on objc (via bridging headers for example) wont' work
echo "Make sure all LLDB configuration files contain the expexted search paths"
XCODE_PROJS=$(find . -name "$XCODE_PROJ_GLOB.xcodeproj")
for PROJ in $XCODE_PROJS; do
    if [ $DESTINATION_TYPE = "simulator" ]; then
        ALL_TARGETS=$(xcodebuild -project $PROJ -sdk iphonesimulator -alltargets -showBuildSettings | grep "TARGET_NAME" | sed -e "s/TARGET_NAME = //g" | xargs)
    else
        ALL_TARGETS=$(xcodebuild -project $PROJ -sdk iphoneos -alltargets -showBuildSettings | grep "TARGET_NAME" | sed -e "s/TARGET_NAME = //g" | xargs)
    fi

    for TARGET in $ALL_TARGETS; do
        if [ $DESTINATION_TYPE = "simulator" ]; then
            XCSETTINGS=$(xcodebuild -project $PROJ -sdk iphonesimulator -target $TARGET -showBuildSettings)
        else
            XCSETTINGS=$(xcodebuild -project $PROJ -sdk iphoneos -target $TARGET -showBuildSettings)
        fi
        HSP=$(echo "$XCSETTINGS" | grep "^[ ]*HEADER_SEARCH_PATHS = " | sed -e "s/HEADER_SEARCH_PATHS = //g" | xargs)
        FSP=$(echo "$XCSETTINGS" | grep "^[ ]*FRAMEWORK_SEARCH_PATHS = " | sed -e "s/FRAMEWORK_SEARCH_PATHS = //g" | xargs)
        PROJ_BASENAME=$(basename $PROJ .xcodeproj)
        LLDB_CONFIG=$(find build -name "*$TARGET.lldbinit" | grep $PROJ_BASENAME.build)

        if [ ! -f "$LLDB_CONFIG" ]; then
            echo "LLDB configuration file doesn't exist: $LLDB_CONFIG"
            exit 1
        fi

        SWIFT_EXTRA_CLANG_FLAGS=$(grep "target.swift-extra-clang-flags" $LLDB_CONFIG)

        for H in $HSP; do
            if [[ "$SWIFT_EXTRA_CLANG_FLAGS" != *"$H"* ]]; then
                echo "Header search path $H not found $LLDB_CONFIG file"
                exit 1
            fi
        done
        for F in $FSP; do
            if [[ "$SWIFT_EXTRA_CLANG_FLAGS" != *"$F"* ]]; then
                echo "Framework search path $F not found $LLDB_CONFIG file"
                exit 1
            fi
        done
    done
done
