set -eux

cd $(dirname $0)

export HEADER_SERACH_PATHS=`grep "HEADER_SEARCH_PATHS" *.xcodeproj/project.pbxproj | grep -o  "bazel-out\S*\.hmap"`

echo "Ensure hmap files do not exist (remove if they do)"
for path in ${HEADER_SERACH_PATHS}; do
    FULL_PATH="../../../$path"
    if [ -f $FULL_PATH ]; then
        rm $FULL_PATH;
        echo "Removed file at $FULL_PATH"; 
    fi
done

