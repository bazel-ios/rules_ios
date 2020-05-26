import XCTest
@testable import TestImports_App

class SwiftTests : XCTestCase {
  func testPasses() {
      _ = EmptyStruct()
      XCTAssertTrue(true)
  }
}
