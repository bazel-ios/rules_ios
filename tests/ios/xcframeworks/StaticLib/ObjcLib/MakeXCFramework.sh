#!/bin/bash

set -eu

# Reference: https://developer.apple.com/forums/thread/666335?answerId=685927022#685927022

SCHEME_NAME="ObjcLib"
CONFIGURATION="Release"
LIBRARY_NAME="lib${SCHEME_NAME}"
SIMULATOR_ARCHIVE_PATH="./build/${CONFIGURATION}/${SCHEME_NAME}-iphonesimulator.xcarchive"
DEVICE_ARCHIVE_PATH="./build/${CONFIGURATION}/${SCHEME_NAME}-iphoneos.xcarchive"

echo "Resetting.."
rm -rf ${SCHEME_NAME}.xcframework

echo "Building..."

# Simulator xcarchive (arm64 + x86_64)
xcodebuild archive \
  ONLY_ACTIVE_ARCH=NO \
  -scheme ${SCHEME_NAME} \
  -project "${SCHEME_NAME}.xcodeproj" \
  -archivePath ${SIMULATOR_ARCHIVE_PATH} \
  -sdk iphonesimulator \
  -configuration ${CONFIGURATION} \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO

# Device xcarchive (arm64)
xcodebuild archive \
  -scheme ${SCHEME_NAME} \
  -project "${SCHEME_NAME}.xcodeproj" \
  -archivePath ${DEVICE_ARCHIVE_PATH} \
  -sdk iphoneos \
  -configuration ${CONFIGURATION} \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO

# Create final xcframework
xcodebuild -create-xcframework \
  -library ${DEVICE_ARCHIVE_PATH}/Products/usr/local/lib/${LIBRARY_NAME}.a \
  -headers ./${SCHEME_NAME}/Headers \
  -library ${SIMULATOR_ARCHIVE_PATH}/Products/usr/local/lib/${LIBRARY_NAME}.a \
  -headers ./${SCHEME_NAME}/Headers \
  -output ./${SCHEME_NAME}.xcframework

echo "Created at: ${SCHEME_NAME}.xcframework"
echo "Cleaning build"
rm -rf build