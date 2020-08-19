set -eux

cd $(dirname $0)

export FSP=`grep "FRAMEWORK_SEARCH_PATHS" *.xcodeproj/project.pbxproj | grep -o "bazel-out[^ \\]*"`
echo "Make sure framework search paths exist after build"
for path in ${FSP}; do
    FULL_PATH="../../../$path"
    if [ -f $FULL_PATH ]; then
        rm -rf $FULL_PATH;
        echo "Removed file at $FULL_PATH";
    fi
done

