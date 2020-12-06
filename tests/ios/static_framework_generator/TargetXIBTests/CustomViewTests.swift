import UIKit
import XCTest
@testable import TargetXIB

final class CustomViewTests: XCTestCase {

    func testCustomView() {
        let view = CustomView.fromNib()
        assert(view != nil, "CustomView is not instantiated.")
    }
}
