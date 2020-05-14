import Foundation
import InputMask
import MixedSourceFramework
import XCTest

class Tests: XCTestCase {
    func test() {
        XCTAssertEqual(snapKitClass, "SnapKit.Constraint")
        XCTAssertEqual(MaskedTextInputListener.inputMaskClass, "InputMask.MaskedTextInputListener")
    }
}
