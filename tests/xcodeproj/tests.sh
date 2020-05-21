set -eux

cd $(dirname $0)

export SIM_DEVICE_ID=`xcodebuild -project Single-Application-Project-AllTargets.xcodeproj -scheme Single-Application-UnitTests -showdestinations | grep "platform:iOS Sim" | head -1 | ruby -e "puts STDIN.read.split(',')[1].split(':').last"`
xcodebuild -project Single-Application-Project-AllTargets.xcodeproj -quiet -scheme Single-Application-UnitTests -destination "id=$SIM_DEVICE_ID" test
xcodebuild -project Single-Application-Project-AllTargets.xcodeproj -quiet -scheme Single-Application-RunnableTestSuite -destination "id=$SIM_DEVICE_ID" test

xcodebuild -project Single-Application-Project-DirectTargetsOnly.xcodeproj -quiet -scheme Single-Application-UnitTests -destination "id=$SIM_DEVICE_ID" test
xcodebuild -project Single-Application-Project-DirectTargetsOnly.xcodeproj -quiet -scheme Single-Application-RunnableTestSuite -destination "id=$SIM_DEVICE_ID" test

xcodebuild -project Test-Target-With-Test-Host-Project.xcodeproj -quiet -scheme TestImports-Unit-Tests -destination "id=$SIM_DEVICE_ID" test

