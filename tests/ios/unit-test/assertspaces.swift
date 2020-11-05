import Foundation
import XCTest

class AssertSpacesTests : XCTestCase {
  func testPasses() {
      XCTAssertEqual(ProcessInfo.processInfo.environment["myvar1"], "this has spaces")
      XCTAssertEqual(ProcessInfo.processInfo.environment["myvar2"], "I guess this one has some too")
  }
}
