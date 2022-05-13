import Foundation

@objc
public class SwiftLogger: NSObject, LoggerProtocol {
    @objc public override init () {}
    @objc public func swiftLog(_ message: String) {
        print(message)
    }
}

