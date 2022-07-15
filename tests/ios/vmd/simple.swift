import XCTest

class SimpleUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testPasses() {
        let app = XCUIApplication()
        app.launch()
        let label = app.staticTexts["Hello world"]
        XCTAssertTrue(label.exists)
    }
}
