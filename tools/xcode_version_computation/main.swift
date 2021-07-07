/// This program writes a full Xcode version based on how Bazel will set this
/// version for the DEVELOPER_DIR
/// https://github.com/bazelbuild/bazel/blob/master/tools/osx/xcode_locator.m
import Foundation

func ExpandVersion(version: String) -> String {
    let components = version.components(separatedBy:".")
    var appendage: String?
    if (components.count == 2) {
        appendage = ".0";
    } else if (components.count == 1) {
        appendage = ".0.0"
    }
    if let appendage = appendage {
        return version + appendage
    }
    return version;
}

enum LoadError: Error {
    case error(_ value: String)
}

func GetFullBazelXcodeVersion(developerDir: String) throws -> String {
    let url = URL(fileURLWithPath: developerDir)
    var plistFormat = PropertyListSerialization.PropertyListFormat.xml
    let bundleURL = url.deletingLastPathComponent().appendingPathComponent("version.plist")
    guard let plistXML = FileManager.default.contents(atPath: bundleURL.path) else {
        throw LoadError.error("Cant load" + bundleURL.path)
    }

    let plistData = try PropertyListSerialization.propertyList(from: plistXML,
        options: [], format: &plistFormat)
    let plist = plistData as? [String: AnyObject] ?? [:]
    guard let shortVersion = plist["CFBundleShortVersionString"] as? String else {
        throw LoadError.error("Missing Xcode CFBundleShortVersionString in version.plist")
    }
    guard let buildVersion = plist["ProductBuildVersion"] as? String else {
        throw LoadError.error("Missing Xcode ProductBuildVersion in version.plist")
    }
    return ExpandVersion(version: shortVersion) + "." + buildVersion
}

let _ = {
    do {
        guard let developerDir = ProcessInfo.processInfo.environment["DEVELOPER_DIR"] else {
            throw LoadError.error("Missing DEVELOPER_DIR")
        }
        let version = try GetFullBazelXcodeVersion(developerDir: developerDir)
        print(version)
    } catch {
        fatalError("\(error)")
    }
}()
