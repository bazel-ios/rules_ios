import UIKit
import CoreData
import Foundation

public class Person: NSManagedObject {
    @nonobjc public static func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged var name: String?
}
