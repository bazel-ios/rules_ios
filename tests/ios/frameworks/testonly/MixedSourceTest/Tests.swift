import Foundation
import MixedSourceFramework
import XCTest
import SwiftLibrary

class Tests: XCTestCase {
    func test() {
        XCTAssertEqual(Foo.aProperty, "hey there!")
    }
}
