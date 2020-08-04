set -eux

cd $(dirname $0)

xcodebuild -project Single-Application-Project-DirectTargetsOnly.xcodeproj -quiet
xcodebuild -project Single-Application-Project-AllTargets.xcodeproj -quiet
xcodebuild -project Test-Target-With-Test-Host-Project.xcodeproj -quiet
# TODO: use strings to test that absolute paths and debug-prefix-map are present in the LocalDebug.swiftmodule. Not sure if this is the right palce to do it. We could also grep out the build event text file maybe.