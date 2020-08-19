set -eux

cd $(dirname $0)

export FSP=`grep "FRAMEWORK_SEARCH_PATHS" *.xcodeproj/project.pbxproj | grep -o "bazel-out[^ \\]*"`
echo "Make sure framework search paths exist after build"
for path in ${FSP}; do
    FULL_PATH="../../../$path"
    if [ ! -e $FULL_PATH ]; then
        echo "File at $FULL_PATH not found!";
        exit 1;
    fi
done
