set -eux

cd $(dirname $0)

if [[ "$(arch)" == "arm"* ]]; then
    echo -e "warning: rerun where Bazel is an x64_64 bazel:\narch -arch x86_64 /bin/bash -l -c \"$0 ${@}\""
fi

xcrun simctl list devices \
| grep -q rules_ios:iPhone-14 || \
        xcrun simctl create "rules_ios:iPhone-14" \
                com.apple.CoreSimulator.SimDeviceType.iPhone-14

export SIM_DEVICE_ID=$(xcodebuild \
  -project Single-Application-Project-AllTargets.xcodeproj \
  -scheme Single-Application-UnitTests \
  -showdestinations \
  -destination "generic/platform=iOS Simulator" | \
  grep "name:rules_ios:iPhone-14" | \
  head -1 | \
  ruby -e "puts STDIN.read.split(',')[1].split(':').last")

xcodebuild -project Single-Application-Project-AllTargets.xcodeproj -quiet -scheme Single-Application-UnitTests -destination "platform=iOS Simulator,id=$SIM_DEVICE_ID" test
xcodebuild -project Single-Application-Project-AllTargets.xcodeproj -quiet -scheme Single-Application-RunnableTestSuite -destination "platform=iOS Simulator,id=$SIM_DEVICE_ID" test

xcodebuild -project Single-Application-Project-DirectTargetsOnly.xcodeproj -quiet -scheme Single-Application-UnitTests -destination "platform=iOS Simulator,id=$SIM_DEVICE_ID" test
xcodebuild -project Single-Application-Project-DirectTargetsOnly.xcodeproj -quiet -scheme Single-Application-RunnableTestSuite -destination "platform=iOS Simulator,id=$SIM_DEVICE_ID" test

xcodebuild -project Test-Target-With-Test-Host-Project.xcodeproj -quiet -scheme TestImports-Unit-Tests -destination "platform=iOS Simulator,id=$SIM_DEVICE_ID" test
