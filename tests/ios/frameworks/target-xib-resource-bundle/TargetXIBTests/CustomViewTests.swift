import UIKit
import XCTest
@testable import TargetXIB

final class CustomViewTests: XCTestCase {

    func testCustomView() {
        let view = CustomView.fromNib()

        assert(view != nil, "CustomView is not instantiated.")
        // This test result in a crash with the following output:
        // <unknown>:0: error: -[TargetXIBTestsLib.CustomViewTests testCustomView] : failed: caught "NSUnknownKeyException", "[<UIView 0x7f8d9fc6de50> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key label."
    }
}
