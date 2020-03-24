set -eux

cd $(dirname $0)

xcodebuild -project Single-Application.xcodeproj -quiet
