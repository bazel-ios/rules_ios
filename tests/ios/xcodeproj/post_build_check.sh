set -eux

cd $(dirname $0)

export HEADER_SERACH_PATHS=`grep "HEADER_SEARCH_PATHS" *.xcodeproj/project.pbxproj | grep -o  "bazel-out\S*\.hmap"`
echo "Make sure hmap files exist after build"
for path in ${HEADER_SERACH_PATHS}; do
    FULL_PATH="../../../$path"
    if [ ! -f $FULL_PATH ]; then
        echo "File at $FULL_PATH not found!";
        exit 1; 
    fi
done
