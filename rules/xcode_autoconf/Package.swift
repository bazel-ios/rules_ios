// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "XcodeAutoConfigure",
    dependencies: [
    ],
    targets: [
        .target(
            name: "XcodeAutoConfigure",
            dependencies: []),
        .testTarget(
            name: "XcodeAutoConfigureTests",
            dependencies: ["XcodeAutoConfigure"]),
    ]
)
