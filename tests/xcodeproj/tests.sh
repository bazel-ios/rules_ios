set -eux

cd $(dirname $0)

xcodebuild -project Single-Application-Project.xcodeproj -quiet -scheme Single-Application-UnitTests test
xcodebuild -project Single-Application-Project.xcodeproj -quiet -scheme Single-Application-RunnableTestSuite test