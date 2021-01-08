import XCTest

class EmptyUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testPasses() {
        XCTAssertTrue(true)
    }
}
