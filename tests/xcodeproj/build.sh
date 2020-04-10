set -eux

cd $(dirname $0)

xcodebuild -project Single-Application-Project-DirectTargetsOnly.xcodeproj -quiet
xcodebuild -project Single-Application-Project-AllTargets.xcodeproj -quiet
xcodebuild -project Test-Target-With-Test-Host-Project -quiet