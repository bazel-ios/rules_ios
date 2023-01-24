set -eux

cd $(dirname $0)

# This implicitly creates the simulators for use if not exist
xcrun simctl list

export SIM_DEVICE_ID=$(xcodebuild \
  -project Single-Application-Project-AllTargets.xcodeproj \
  -scheme Single-Application-UnitTests \
  -showdestinations \
  -destination "generic/platform=iOS Simulator" | \
  grep "name:iPhone 14" | \
  head -1 | \
  ruby -e "puts STDIN.read.split(',')[1].split(':').last")

xcodebuild -project Single-Application-Project-AllTargets.xcodeproj -quiet -scheme Single-Application-UnitTests -destination "platform=iOS Simulator,id=$SIM_DEVICE_ID" test
xcodebuild -project Single-Application-Project-AllTargets.xcodeproj -quiet -scheme Single-Application-RunnableTestSuite -destination "platform=iOS Simulator,id=$SIM_DEVICE_ID" test

xcodebuild -project Single-Application-Project-DirectTargetsOnly.xcodeproj -quiet -scheme Single-Application-UnitTests -destination "platform=iOS Simulator,id=$SIM_DEVICE_ID" test
xcodebuild -project Single-Application-Project-DirectTargetsOnly.xcodeproj -quiet -scheme Single-Application-RunnableTestSuite -destination "platform=iOS Simulator,id=$SIM_DEVICE_ID" test

xcodebuild -project Test-Target-With-Test-Host-Project.xcodeproj -quiet -scheme TestImports-Unit-Tests -destination "platform=iOS Simulator,id=$SIM_DEVICE_ID" test
