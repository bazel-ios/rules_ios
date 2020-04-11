import XCTest

class SwiftTests : XCTestCase {
  func testPasses() {
      let envvarvalue = ProcessInfo.processInfo.environment["test_envvar_key"]
      XCTAssertEqual(envvarvalue, "test_envvar_value")
      let arguments = ProcessInfo.processInfo.arguments
      XCTAssertEqual(6, arguments.count)
      XCTAssertEqual(arguments[1], "commandline_arg1")
  }
}

