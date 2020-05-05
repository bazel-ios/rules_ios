set -eux

cd $(dirname $0)

xcodebuild -project Single-Application-Project-DirectTargetsOnly.xcodeproj -quiet
xcodebuild -project Single-Application-Project-AllTargets.xcodeproj -quiet