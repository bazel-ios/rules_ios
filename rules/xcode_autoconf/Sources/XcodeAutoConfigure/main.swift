import Foundation
// TODO:
// Determines selected Xcode based on env: intelligent noop here

// TODO:
// Otherwise, dump the JSON SDKS to starlark if it's changed. Note: This needs
// a dep on the DEVELOPER_DIR and env.
// ( "xcrun", )

// TODO:
// Write a BUILD file for the current executing Xcode

/* Needs something that looking like this:
xcode_version(
  name = 'version11_2_1_11B500',
  version = '11.2.1.11B500',
  aliases = ['11.2.1' ,'11.2.1.11B500' ,'11.2' ,'11'],
  default_ios_sdk_version = '13.2',
  default_tvos_sdk_version = '13.2',
  default_macos_sdk_version = '10.15',
  default_watchos_sdk_version = '6.1',
)
xcode_config(name = 'host_xcodes',
  versions = [':version12_1_0_12A7403', ':version11_6_0_11E708', ':version11_2_1_11B500'],
  default = ':version11_2_1_11B500',
)
available_xcodes(name = 'host_available_xcodes',
  versions = [':version12_1_0_12A7403', ':version11_6_0_11E708', ':version11_2_1_11B500'],
  default = ':version11_2_1_11B500',
)
*/

func GetVersion(developerDir: String) throws -> String {
    let url = try URL(fileURLWithPath: developerDir)
    guard url.lastPathComponent == "Developer" else {
        print("Invalid Developer dir")
        exit(1)
    }

    let bundleURL = url.deletingLastPathComponent().deletingLastPathComponent()
    guard let infoDictionary = Bundle(url: bundleURL)?.infoDictionary else {
        print("Error")
        exit(1)
    }

    //print("InfoDict", infoDictionary)
    guard let shortVersion = infoDictionary["CFBundleShortVersionString"] as? String else {
        print("Missing Xcode short version")
        exit(1)
    }

    guard let buildVersion = infoDictionary["DTPlatformBuild"] as? String else {
        print("Missing Xcode build version")
        exit(1)
    }
    return shortVersion + "." + buildVersion
}

func GetDeveloperDir() throws -> String {
    guard #available(macOS 10.13, *) else {
        fatalError("unsupported macOS version")
    }

    if let developerDir = ProcessInfo.processInfo.environment["DEVELOPER_DIR"] {
        return developerDir
    }
    // Assume that this combination of xcrun and xcodebuild prints the versions
    // for the current developer dir. If there is no developer dir, it falls
    // back to xcode-select's value
    let binPath = "/usr/bin/xcode-select"
    let process = Process()
    process.executableURL = URL(fileURLWithPath: binPath)
    process.arguments = [ "-p" ]
    let pipe = Pipe()
    process.standardOutput = pipe

    try process.run()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: data, encoding: .utf8) else {
      fatalError("Invalid output")
    }
    return output.trimmingCharacters(in: .whitespacesAndNewlines)
}


func GetSDKS() throws -> String {
    guard #available(macOS 10.13, *) else {
        fatalError("unsupported macOS version")
    }

    // Assume that this combination of xcrun and xcodebuild prints the versions
    // for the current developer dir. If there is no developer dir, it falls
    // back to xcode-select's value
    let binPath = "/usr/bin/xcrun"
    let process = Process()
    process.executableURL = URL(fileURLWithPath: binPath)
    process.arguments = [ "xcodebuild", "-version", "-sdk", "-json" ]
    let pipe = Pipe()
    process.standardOutput = pipe

    try process.run()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    return ""
}

func Write() throws -> Void {
    let dir = try GetDeveloperDir()
    print("DIR", dir)
    let version = try GetVersion(developerDir: dir)
    print("VERSION", version)
    //let SDKContents = try GetSDKS()
}

let _ = {
    setbuf(__stdoutp, nil);


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
