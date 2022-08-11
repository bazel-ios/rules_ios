#!/bin/bash

set -eu

# Reference: https://developer.apple.com/forums/thread/666335?answerId=685927022#685927022

SCHEME_NAME="SwiftLib"
CONFIGURATION="Release"
LIBRARY_NAME="lib${SCHEME_NAME}"
SIMULATOR_ARCHIVE_PATH="./build/${CONFIGURATION}/${SCHEME_NAME}-iphonesimulator.xcarchive"
DEVICE_ARCHIVE_PATH="./build/${CONFIGURATION}/${SCHEME_NAME}-iphoneos.xcarchive"
XCFRAMEWORK_NAME="${SCHEME_NAME}.xcframework"

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
  -library ${SIMULATOR_ARCHIVE_PATH}/Products/usr/local/lib/${LIBRARY_NAME}.a \
  -output ./${XCFRAMEWORK_NAME}

# Copy the .swiftmodule into the .xcframework slices
DERIVED_DATA="`ls -d ${HOME}/Library/Developer/Xcode/DerivedData/${SCHEME_NAME}-*`"
BUILD_PRODUCTS_PATH="${DERIVED_DATA}/Build/Intermediates.noindex/ArchiveIntermediates/${SCHEME_NAME}/BuildProductsPath"
SWIFTMODULE_PATH="${BUILD_PRODUCTS_PATH}/${CONFIGURATION}-iphoneos/${SCHEME_NAME}.swiftmodule"
# Copy to device archive (arm64)
cp -a "${SWIFTMODULE_PATH}" "${XCFRAMEWORK_NAME}/ios-arm64"
# Copy to simulator archive (arm64 + x86_64)
cp -a "${SWIFTMODULE_PATH}" "${XCFRAMEWORK_NAME}/ios-arm64_x86_64-simulator"

echo "Created at: ${XCFRAMEWORK_NAME}"
echo "Cleaning build"
rm -rf build