set -eux

cd $(dirname $0)

# Make sure there are simulators avilable as destinations
xcrun simctl list

export PROJECT_AND_SCHEME="-project Single-Static-Framework-Project.xcodeproj -scheme ObjcFrameworkTests"
export SIM_DEVICE_ID=$(xcodebuild \
$PROJECT_AND_SCHEME \
-showdestinations \
-destination "generic/platform=iOS Simulator" | \
grep "platform:iOS Sim" | \
grep "name:iPhone 14" | \
head -1 | \
ruby -e "puts STDIN.read.split(',')[1].split(':').last")

xcodebuild $PROJECT_AND_SCHEME -destination "id=$SIM_DEVICE_ID" -quiet test

# Test running ObjcFrameworkTests using the ObjcFramework scheme
export PROJECT_AND_NON_TEST_SCHEME="-project Single-Static-Framework-Project.xcodeproj -scheme ObjcFramework"
xcodebuild $PROJECT_AND_NON_TEST_SCHEME -destination "id=$SIM_DEVICE_ID" -quiet test
