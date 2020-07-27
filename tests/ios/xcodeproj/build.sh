set -eux

cd $(dirname $0)

# Make sure there are simulators avilable as destinations
xcrun simctl list

export PROJECT_AND_SCHEME="-project Single-Static-Framework-Project.xcodeproj -scheme ObjcFrameworkTests"
export SIM_DEVICE_ID=`xcodebuild $PROJECT_AND_SCHEME -showdestinations | grep "platform:iOS Sim" | head -1 | ruby -e "puts STDIN.read.split(',')[1].split(':').last"`

xcodebuild $PROJECT_AND_SCHEME -destination "id=$SIM_DEVICE_ID" -quiet 
