import Foundation

@objc
public class SwiftLogger: NSObject {
    @objc public override init () {}
    @objc public func swiftLog(_ message: String) {
        print(message)
    }
}

