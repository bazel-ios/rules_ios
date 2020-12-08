set -eux

cd $(dirname $0)

# Make sure there are simulators avilable as destinations
xcrun simctl list

export SAMPLE_PROJECT_AND_SCHEME="-project Single-Static-Framework-Project.xcodeproj -scheme ObjcFrameworkTests"
export SIM_DEVICE_ID=$(xcodebuild $SAMPLE_PROJECT_AND_SCHEME -showdestinations -destination "generic/platform=iOS Simulator" | grep "platform:iOS Sim" | head -1 | ruby -e "puts STDIN.read.split(',')[1].split(':').last")

for i in $(find *.xcodeproj -maxdepth 0 -type d); do
    xcodebuild -project $i -alltargets -destination "id=$SIM_DEVICE_ID" -quiet
done
