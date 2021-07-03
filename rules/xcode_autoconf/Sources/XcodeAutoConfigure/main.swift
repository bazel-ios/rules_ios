import Foundation
// TODO:
// Determines selected Xcode based on env: intelligent noop here

// TODO:
// Otherwise, dump the JSON SDKS to starlark if it's changed. Note: This needs
// a dep on the DEVELOPER_DIR and env.
// ( "xcrun", )

// TODO:
// Write a BUILD file for the current executing Xcode

let STR = """
xcode_version(
  name = 'version12_1_0_12A7403',
  version = '12.1.0.12A7403',
  aliases = ['12.1.0' ,'12' ,'12.1.0.12A7403' ,'12.1'],
  default_ios_sdk_version = '14.1',
  default_tvos_sdk_version = '14.0',
  default_macos_sdk_version = '10.15',
  default_watchos_sdk_version = '7.0',
)
xcode_config(name = 'host_xcodes',
  versions = [':version12_1_0_12A7403'],
  default = ':version12_1_0_12A7403',
)
available_xcodes(name = 'host_available_xcodes',
  versions = [':version12_1_0_12A7403'],
  default = ':version12_1_0_12A7403',
)
"""


func GetVersion(developerDir: String) throws -> String {
    let url = URL(fileURLWithPath: developerDir)
    guard url.lastPathComponent == "Developer" else {
        print("Invalid Developer dir")
        exit(1)
    }

    var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.

    let bundleURL = url.deletingLastPathComponent().appendingPathComponent("version.plist")

    guard let plistXML = FileManager.default.contents(atPath: bundleURL.path) else {
        print("Cant load" + bundleURL.path)
exit(1)
    }

   print("Cant load\(plistXML)")
    let plistData = try PropertyListSerialization.propertyList(from: plistXML,
        options: .mutableContainersAndLeaves, format: &propertyListFormat)


    let infoDictionary = plistData as! [String: AnyObject]
    print("DICTP:", infoDictionary)

    //print("InfoDict", infoDictionary)
    guard let shortVersion = infoDictionary["CFBundleShortVersionString"] as? String else {
        print("Missing Xcode short version")
        exit(1)
    }

    guard let buildVersion = infoDictionary["ProductBuildVersion"] as? String else {
        print("Missing Xcode build version")
        exit(1)
    }
    return shortVersion + ".0." + buildVersion
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

struct XcodeSDKVersionEntry: Codable {
    var platform: String
    var sdkVersion: String
}

func GetSDKS() throws -> [XcodeSDKVersionEntry] {
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
    let jsonData = pipe.fileHandleForReading.readDataToEndOfFile()
    let entries = try JSONDecoder().decode([XcodeSDKVersionEntry].self, from: jsonData)
    return entries
}

func getSDKVersion(sdkPath: String) -> String {
   return ""
}

func GetBuildFile() throws -> String {
    let dir = try GetDeveloperDir()
    let version = try GetVersion(developerDir: dir)
    let SDKContents = try GetSDKS()

    // Load the SDKAttributes
    let SDKAttributes = SDKContents.reduce(into: [String: String]()) {
        accum, next in
        switch next.platform {
        case "watchos":
            accum["default_watchos_sdk_version"] = "'\(next.sdkVersion)'"
        case "iphoneos":
            accum["default_ios_sdk_version"] = "'\(next.sdkVersion)'"
        case "appletvos":
            accum["default_tvos_sdk_version"] = "'\(next.sdkVersion)'"
        case "macosx":
            accum["default_macos_sdk_version"] = "'\(next.sdkVersion)'"
            accum["default_macos_sdk_version"] = "'10.15'"
        default:
            break
        }
    }
    var allAttributes = SDKAttributes
    let versionP = "version12_1_0_12A7403"
    let nameAttr = "'\(version)'"
    allAttributes["version"] = "'\(version)'"
    allAttributes["aliases"] = "['\(version)']"
    allAttributes["name"] = nameAttr
    let arguments = allAttributes.reduce(into: "") {
        accum, next in
        accum += "\(next.key)=\(next.value),\n"
    }
    return """
    xcode_version(\(arguments))
    available_xcodes(name = 'host_available_xcodes',
      versions = [\(nameAttr)],
      default = \(nameAttr),
    )
    xcode_config(name = 'host_xcodes',
      versions = [\(nameAttr)],
      default = \(nameAttr),
    )
    """
}

let _ = {
    setbuf(__stdoutp, nil);
    do {
        let buildFileContents = try GetBuildFile()
        //let buildFileContents = STR
        print(buildFileContents)
        let ws = "workspace(name = \"local_config_xcode\")"
        try buildFileContents.write(toFile: "BUILD.bazel", atomically: true, encoding: .utf8)
        try ws.write(toFile: "WORKSPACE", atomically: true, encoding: .utf8)
    } catch {
        print("ERROR \(error)")
        exit(1)
    }
}()
