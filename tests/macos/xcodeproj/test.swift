import XCTest

class SwiftTests : XCTestCase {
  func testPasses() {
    XCTAssertTrue(true)
  }
  func testPreprocessorDefinesFlag() {
      #if REQUIRED_DEFINED_FLAG
        XCTAssertTrue(true)
      #else
        NoteThisShouldShowNoErrorInsideXCodeOrBuildError
      #endif // REQUIRED_DEFINED_FLAG
    
      #if FLAG_WITH_VALUE_ZERO
        NoteThisShouldShowNoErrorInsideXCodeOrBuildError
        XCTAssertTrue(false)
      #else
      #endif //FLAG_WITH_VALUE_ZERO

  }
  func testTestEnvArgsMatches() {
    XCTAssertEqual(ProcessInfo.processInfo.environment["test_envvar_key1"], "test_envvar_value1")
    XCTAssertEqual(ProcessInfo.processInfo.environment["test_envvar_key2"], "test_envvar_value2_overridenvalue")
  }
  func testTestLaunchArgsMatches() {
    XCTAssertTrue(ProcessInfo.processInfo.arguments.contains("-h"))
  }
}

