#!/bin/bash

set -eu

PROJECT_NAME="BasicXCFramework"
CONFIGURATION="Release"

build_xcframework () {
  SCHEME_NAME=$1
  SIMULATOR_ARCHIVE_PATH="./build/${CONFIGURATION}/${SCHEME_NAME}-iphonesimulator.xcarchive"
  DEVICE_ARCHIVE_PATH="./build/${CONFIGURATION}/${SCHEME_NAME}-iphoneos.xcarchive"
  
  echo "Resetting '${SCHEME_NAME}'..."
  rm -rf ${SCHEME_NAME}.xcframework

  echo "Building '${SCHEME_NAME}'..."

  # Simulator xcarchive (arm64 + x86_64)
  xcodebuild archive \
    ONLY_ACTIVE_ARCH=NO \
    -scheme ${SCHEME_NAME} \
    -project "${PROJECT_NAME}.xcodeproj" \
    -archivePath ${SIMULATOR_ARCHIVE_PATH} \
    -sdk iphonesimulator \
    -configuration ${CONFIGURATION} \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO

  # Device xcarchive (arm64)
  xcodebuild archive \
    -scheme ${SCHEME_NAME} \
    -project "${PROJECT_NAME}.xcodeproj" \
    -archivePath ${DEVICE_ARCHIVE_PATH} \
    -sdk iphoneos \
    -configuration ${CONFIGURATION} \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO

  # Create final xcframework
  xcodebuild -create-xcframework \
    -framework ${DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/${SCHEME_NAME}.framework \
    -framework ${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/${SCHEME_NAME}.framework \
    -output ./${SCHEME_NAME}.xcframework

  echo "Created at: ${SCHEME_NAME}.xcframework"
  echo "Cleaning build"
  rm -rf build
}

build_xcframework "BasicXCFrameworkDynamic"
build_xcframework "BasicXCFrameworkStatic"
