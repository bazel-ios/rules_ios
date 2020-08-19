set -eux

cd $(dirname $0)

export HSP=`grep "HEADER_SEARCH_PATHS" *.xcodeproj/project.pbxproj | grep -o  "bazel-out\S*\.hmap"`
echo "Make sure hmap files exist after build"
for path in ${HSP}; do
    FULL_PATH="../../../$path"
    if [ ! -f $FULL_PATH ]; then
        echo "File at $FULL_PATH not found!";
        exit 1;
    fi
done

export FSP=`grep "FRAMEWORK_SEARCH_PATHS" *.xcodeproj/project.pbxproj | grep -o "bazel-out[^ \\]*"`
echo "Make sure framework search paths exist after build"
for path in ${FSP}; do
    FULL_PATH="../../../$path"
    if [ ! -e $FULL_PATH ]; then
        echo "File at $FULL_PATH not found!";
        exit 1;
    fi
done
