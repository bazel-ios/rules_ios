# XCFramework Tests

This directory contains tests and fixtures for testing `rules_ios` against XCFrameworks.

## Generating the BasicXCFramework fixture

To create a `.xcframework` from the BasicXCFramework Xcode project you can follow the below steps.
Note: This fixture tests specifically how some xcframeworks include `.swiftmodule` **source** files within a `.swiftmodule` directory.

0. Run the below commands from the `BasicXCFramework` directory

1. Create the framework for iOS simulator SDKs

    ```sh
    xcodebuild archive \
        -scheme BasicXCFramework \
        -archivePath /tmp/BasicXCFramework-iphonesimulator.xcarchive \
        -sdk iphonesimulator \
        SKIP_INSTALL=NO
    ```

2. Create the framework for iPhone SDKs

    ```sh
    xcodebuild archive \
        -scheme BasicXCFramework \
        -archivePath /tmp/BasicXCFramework-iphoneos.xcarchive \
        -sdk iphoneos \
        SKIP_INSTALL=NO
    ```

3. Create the XCFramework combining both of the above frameworks

    ```sh
    xcodebuild -create-xcframework \
        -framework /tmp/BasicXCFramework-iphonesimulator.xcarchive/Products/Library/Frameworks/BasicXCFramework.framework \
        -framework /tmp/BasicXCFramework-iphoneos.xcarchive/Products/Library/Frameworks/BasicXCFramework.framework \
        -output /tmp/BasicXCFramework.xcframework
    ```

4. Copy the `.swiftmodule` files from step 1 & 2 into the XCFramework

    ```sh
    cp /tmp/BasicXCFramework-iphoneos.xcarchive/Products/Library/Frameworks/BasicXCFramework.framework/Modules/BasicXCFramework.swiftmodule/*.swiftmodule /tmp/BasicXCFramework.xcframework/ios-arm64/BasicXCFramework.framework/Modules/BasicXCFramework.swiftmodule
    ```

    ```sh
    cp /tmp/BasicXCFramework-iphonesimulator.xcarchive/Products/Library/Frameworks/BasicXCFramework.framework/Modules/BasicXCFramework.swiftmodule/*.swiftmodule /tmp/BasicXCFramework.xcframework/ios-arm64_x86_64-simulator/BasicXCFramework.framework/Modules/BasicXCFramework.swiftmodule
    ```

5. Move the XCFramework to the directory

    ```sh
    mv -f /tmp/BasicXCFramework.xcframework .
    ```
