set -eux

cd $(dirname $0)

export HEADER_SERACH_PATHS=`grep "HEADER_SEARCH_PATHS" *.xcodeproj/project.pbxproj | grep -o  "bazel-out\S*\.hmap"`

echo "Ensure hmap files do not exist (or remove if they do)"
for path in ${HEADER_SERACH_PATHS}; do
    FULL_PATH="../../../$path"
    if [ -f $FULL_PATH ]; then
        rm $FULL_PATH;
        echo "Removed file at $FULL_PATH"; 
    fi
done

# Make sure there are simulators avilable as destinations
xcrun simctl list

export PROJECT_AND_SCHEME="-project Single-Static-Framework-Project.xcodeproj -scheme ObjcFrameworkTests"
export SIM_DEVICE_ID=`xcodebuild $PROJECT_AND_SCHEME -showdestinations | grep "platform:iOS Sim" | head -1 | ruby -e "puts STDIN.read.split(',')[1].split(':').last"`

xcodebuild $PROJECT_AND_SCHEME -destination "id=$SIM_DEVICE_ID" -quiet 

echo "Make sure hmap files exist after build"
for path in ${HEADER_SERACH_PATHS}; do
    FULL_PATH="../../../$path"
    if [ ! -f $FULL_PATH ]; then
        echo "File at $FULL_PATH not found!";
        exit 1; 
    fi
done
