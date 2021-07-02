import Foundation
// TODO:
// Determines selected Xcode based on env: intelligent noop here

// TODO:
// Otherwise, dump the JSON SDKS to starlark if it's changed. Note: This needs
// a dep on the DEVELOPER_DIR and env.
// ( "xcrun", "xcodebuild", "-version", "-sdk" )

// TODO:
// Write a BUILD file for the current executing Xcode

let buildFileContents = "#HELLO WORLD"
try buildFileContents.write(toFile: "BUILD.bazel", atomically: true, encoding: .utf8)
