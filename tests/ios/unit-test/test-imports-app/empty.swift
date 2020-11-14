import Foundation
import SomeFramework

@objc public class EmptyClass: NSObject {}
internal struct EmptyStruct {}

@objc public extension FooFramework {
    func returnOne() -> NSInteger {
        1
    }
}
