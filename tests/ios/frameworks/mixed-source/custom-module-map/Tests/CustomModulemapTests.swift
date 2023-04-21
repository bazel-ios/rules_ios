import CustomModuleMap
import CustomModuleMap.A_CustomModuleMapAdditions
import CustomModuleMap.SuperSecret
import XCTest

class S: SuperSecret {
    let a: A
    let c: C
    func addition() {
        a.addition()
    }
    override init() {
        a = A()
        c = C()
        super.init()
    }
}

final class SwiftTests: XCTestCase {
    func testTrue() {
        XCTAssertTrue(true)
    }
}
