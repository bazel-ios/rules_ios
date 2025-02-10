import Foundation
import XCTest

@testable import BundleInDataResourcesFramework

class BundleInDataTests: XCTestCase {

    func testBundleInData() throws {
        let fakeDataPath = try XCTUnwrap(Bundle.bundleInDataResources.path(forResource: "fake-data", ofType: "txt"))
        let fakeDataContents = try XCTUnwrap(String(contentsOfFile: fakeDataPath))

        XCTAssertEqual(
            fakeDataContents,
            "fake-data\n"
        )
    }
}
