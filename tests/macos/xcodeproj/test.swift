import XCTest
import TestHostModule

class SwiftTests : XCTestCase {
  func testPasses() {
    XCTAssertTrue(true)
  }
  func testPreprocessorDefinesFlag() {
      #if REQUIRED_DEFINED_FLAG
      #else
          XCTAssertTrue(false)
      #endif // REQUIRED_DEFINED_FLAG
  }
  func testTestEnvArgsMatches() {
    XCTAssertEqual(ProcessInfo.processInfo.environment["test_envvar_key1"], "test_envvar_value1")
    XCTAssertEqual(ProcessInfo.processInfo.environment["test_envvar_key2"], "test_envvar_value2_overridenvalue")
  }
  func testTestLaunchArgsMatches() {
    XCTAssertTrue(ProcessInfo.processInfo.arguments.contains("-h"))
  }
}

