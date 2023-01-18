set -eux
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

if [ $DESTINATION_TYPE = "simulator" ]; then
    # Make sure there are simulators avilable as destinations
    xcrun simctl list

    export SAMPLE_PROJECT_AND_SCHEME="-project Single-Static-Framework-Project.xcodeproj -scheme ObjcFrameworkTests"
    export HOST_ARCH=$(uname -m)
    export SIM_DEVICE_ID=$(xcodebuild \
    $SAMPLE_PROJECT_AND_SCHEME \
    -showdestinations \
    -destination "generic/platform=iOS Simulator" | \
    grep "platform:iOS Sim" | \
    grep "name:iPhone 14" | \
    head -1 | \
    ruby -e "puts STDIN.read.split(',')[1].split(':').last")
fi

for i in $(find $XCODE_PROJ_GLOB.xcodeproj -maxdepth 0 -type d); do
    if [ $DESTINATION_TYPE = "simulator" ]; then
        xcodebuild -project $i -alltargets -sdk iphonesimulator -arch "$HOST_ARCH" -destination "platform=iOS Simulator,id=$SIM_DEVICE_ID" -quiet
    else
        xcodebuild -project $i -alltargets -sdk iphoneos -quiet
    fi
done
