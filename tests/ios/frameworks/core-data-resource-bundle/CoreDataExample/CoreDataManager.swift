import CoreData

public final class CoreDataManager {

    // MARK: - Properties
    private let modelName: String

    // MARK: - Initialization
    init(modelName: String = "Model") {
        self.modelName = modelName
    }

    // MARK: - Core Data Stack
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        return managedObjectContext
    }()

    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle(for: Self.self).url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }

        return managedObjectModel
    }()

    private lazy var persistentStoreCoordinatorUrl: URL = {
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"

        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        return persistentStoreURL
    }()

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)


        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreCoordinatorUrl,
                                                              options: nil)
        } catch {
            fatalError("Unable to Load Persistent Store")
        }

        return persistentStoreCoordinator
    }()

    public func savePerson(name: String) {
        let person = NSEntityDescription.insertNewObject(
            forEntityName: "Person",
            into: managedObjectContext
        ) as? Person
        person?.name = name
        try? managedObjectContext.save()
    }

    public func fetchPeople() -> [Person] {
        let result: [Person] = (try? managedObjectContext.fetch(Person.fetchRequest())) ?? []
        return result
    }

    public func nuke() {
        try? FileManager.default.removeItem(at: persistentStoreCoordinatorUrl)
    }
}
