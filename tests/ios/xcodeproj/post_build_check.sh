set -eu

cd $(dirname $0)

binary=$(ls ../../../bazel-out/*/bin/tests/ios/unit-test/test-imports-app/TestImports-App_archive-root/Payload/TestImports-App.app/TestImports-App)

# The linked binary should include ASTs for the transitive dependency as well
export NUM_LINKED_ASTS=$(dsymutil -s "$binary" | grep -c N_AST)
[[ $NUM_LINKED_ASTS == 2 ]]

export HSP=$(grep "HEADER_SEARCH_PATHS" *.xcodeproj/project.pbxproj | grep -o "bazel-out\S*\.hmap")
echo "Make sure hmap files exist after build"
for path in ${HSP}; do
    FULL_PATH="../../../$path"
    if [ ! -f $FULL_PATH ]; then
        echo "File at $FULL_PATH not found!"
        exit 1
    fi
done

export FSP=$(grep "FRAMEWORK_SEARCH_PATHS" *.xcodeproj/project.pbxproj | grep -o "bazel-out[^ \]*")
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