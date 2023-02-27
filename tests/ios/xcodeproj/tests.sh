set -eux

cd $(dirname $0)

if [[ "$(arch)" == "arm"* ]]; then
    echo -e "warning: rerun where Bazel is an x64_64 bazel:\narch -arch x86_64 /bin/bash -l -c \"$0 ${@}\""
fi

xcrun simctl list devices \
| grep -q rules_ios:iPhone-14 || \
        xcrun simctl create "rules_ios:iPhone-14" \
                com.apple.CoreSimulator.SimDeviceType.iPhone-14

export PROJECT_AND_SCHEME="-project Single-Static-Framework-Project.xcodeproj -scheme ObjcFrameworkTests"
export SIM_DEVICE_ID=$(xcodebuild \
$PROJECT_AND_SCHEME \
-showdestinations \
-destination "generic/platform=iOS Simulator" | \
grep "platform:iOS Sim" | \
grep "name:rules_ios:iPhone-14" | \
head -1 | \
ruby -e "puts STDIN.read.split(',')[1].split(':').last")

xcodebuild $PROJECT_AND_SCHEME -destination "id=$SIM_DEVICE_ID" -quiet test

# Test running ObjcFrameworkTests using the ObjcFramework scheme
export PROJECT_AND_NON_TEST_SCHEME="-project Single-Static-Framework-Project.xcodeproj -scheme ObjcFramework"
xcodebuild $PROJECT_AND_NON_TEST_SCHEME -destination "id=$SIM_DEVICE_ID" -quiet test
