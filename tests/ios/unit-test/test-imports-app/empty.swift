import Foundation
import SomeFramework
import TensorFlowLiteC
import TensorFlowLiteCCoreML
import MBProgressHUD

@objc public class EmptyClass: NSObject {

    @objc public static func emptyDescription() -> String {
        return ""
    }

    @objc public func emptyDescription() -> String {
        return ""
    }

}
internal struct EmptyStruct {}
