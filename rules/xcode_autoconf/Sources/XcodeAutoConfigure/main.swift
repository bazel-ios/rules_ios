import Foundation
// TODO:
// Determines selected Xcode based on env: intelligent noop here

// TODO:
// Otherwise, dump the JSON SDKS to starlark if it's changed. Note: This needs
// a dep on the DEVELOPER_DIR and env.
// ( "xcrun", )

// TODO:
// Write a BUILD file for the current executing Xcode


func GetSDKS() throws -> String {
    guard #available(macOS 10.13, *) else {
        fatalError("X")
    }
    guard let developerDir = ProcessInfo.processInfo.environment["DEVELOPER_DIR"] else {
        fatalError("MissingDeveloperDir")
    }
    print("DeveloperDir", developerDir)
    let binPath = "/usr/bin/xcrun"
    let process = Process()
    process.executableURL = URL(fileURLWithPath: binPath)

    process.arguments = [ "xcodebuild", "-version", "-sdk"  ]
    let pipe = Pipe()
    process.standardOutput = pipe

    try process.run()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    print("OUT", output)
    return ""
}

func Write() throws -> Void {
    let SDKContents = try GetSDKS()
}

let _ = {
    do {
        print("TRY")
        try Write()
        let buildFileContents = "#HELLO WORLD"
        try buildFileContents.write(toFile: "BUILD.bazel", atomically: true, encoding: .utf8)
    } catch {
        print("ERROR \(error)")
        exit(1)
    }
}()
