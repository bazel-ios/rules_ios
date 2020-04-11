set -eux

cd $(dirname $0)

# xcodebuild -project Single-Application-Project.xcodeproj -quiet
export SIM_DEVICE_ID=`xcodebuild -project Single-Application-Project.xcodeproj -scheme "Single-Application-UnitTests" -showdestinations | grep "platform:iOS Sim" | head -1 | ruby -e "puts STDIN.read.split(',')[1].split(':').last"`
xcodebuild -project Single-Application-Project.xcodeproj -destination "id=$SIM_DEVICE_ID"
ls -R1 /Users/runner/Library/Developer/Xcode/DerivedData/Single-Application-Project-*
xcodebuild -project Single-Application-Project.xcodeproj -scheme "Single-Application-UnitTests"  test-without-building -destination "id=$SIM_DEVICE_ID"

