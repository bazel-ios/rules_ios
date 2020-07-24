set -eux

cd $(dirname $0)

export PROJECT_AND_SCHEME="-project Single-Static-Framework-Project.xcodeproj -scheme ObjcFramework"
export SIM_DEVICE_ID=`xcodebuild $PROJECT_AND_SCHEME -showdestinations | grep "platform:iOS Sim" | head -1 | ruby -e "puts STDIN.read.split(',')[1].split(':').last"`
echo $SIM_DEVICE_ID
xcodebuild $PROJECT_AND_SCHEME -destination "id=$SIM_DEVICE_ID" -quiet
