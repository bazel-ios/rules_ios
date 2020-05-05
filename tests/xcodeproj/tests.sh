set -eux

cd $(dirname $0)

xcodebuild -project Single-Application-Project-AllTargets.xcodeproj -quiet -scheme Single-Application-UnitTests test
xcodebuild -project Single-Application-Project-AllTargets.xcodeproj -quiet -scheme Single-Application-RunnableTestSuite test

xcodebuild -project Single-Application-Project-DirectTargetsOnly.xcodeproj -quiet -scheme Single-Application-UnitTests test
xcodebuild -project Single-Application-Project-DirectTargetsOnly.xcodeproj -quiet -scheme Single-Application-RunnableTestSuite test