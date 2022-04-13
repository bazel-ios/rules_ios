import Foundation
import XCTest

/// Observes significant events in the progress of test runs
/// Demonstrates defining NSPrincipalClass in unit test bundles.
@objc(TestSuiteObserver)
class TestSuiteObserver: NSObject, XCTestObservation {

    // MARK: - Life Cycle

    override init() {
        super.init()

        XCTestObservationCenter.shared.addTestObserver(self)
    }

    // MARK: - Test Observation

    func testBundleWillStart(_ testBundle: Bundle) {}
}
