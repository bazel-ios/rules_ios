import XCTest
@testable import CoreDataExample

class CoreDataExampleTests: XCTestCase {
    func test() {
        let coreData = CoreDataManager()
        coreData.nuke()

        coreData.savePerson(name: "Peter")
        let people = coreData.fetchPeople()

        XCTAssertEqual(people.count, 1)
        XCTAssertEqual(people.first?.name, "Peter")
    }
}
