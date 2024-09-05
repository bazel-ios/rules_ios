import Foundation
import SomeFramework
import Basic

@objc public class EmptyClass: NSObject {

    @objc public static func emptyDescription() -> String {
        print(BasicString)
        print(EmptyClass.emptyDescription)
        return ""
    }

    @objc public func emptyDescription() -> String {
        return ""
    }

}
internal struct EmptyStruct {}
