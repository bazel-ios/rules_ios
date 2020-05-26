import XCTest

class SwiftTests : XCTestCase {
  func testPasses() {
    XCTAssertTrue(true)
  }
  func testTestEnvArgsMatches() {
    XCTAssertEqual(ProcessInfo.processInfo.environment["test_envvar_key1"], "test_envvar_value1")
    XCTAssertEqual(ProcessInfo.processInfo.environment["test_envvar_key2"], "test_envvar_value2_overridenvalue")
  }
  func testTestLaunchArgsMatches() {
    XCTAssertTrue(ProcessInfo.processInfo.arguments.contains("-h"))
  }
}

