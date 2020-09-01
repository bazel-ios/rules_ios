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
        guard let bundle = Bundle(for: Self.self)
            .url(forResource: "CoreDataExample", withExtension: "bundle")
            .flatMap(Bundle.init(url:)) else {
            fatalError("Unable to Find bundle")
        }

        guard let modelURL = bundle.url(forResource: self.modelName, withExtension: "momd") else {
            fatalError("Unable to Find Data Model in bundle at path \(bundle.bundleURL)")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }

        return managedObjectModel
    }()

    private lazy var persistentStoreCoordinatorUrl: URL = {
        let storeName = "\(self.modelName).sqlite"

        guard let documentsDirectoryURL = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
            ) else {
            fatalError("Document directory is not ready")
        }

        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        return persistentStoreURL
    }()

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)

        do {
            try persistentStoreCoordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: persistentStoreCoordinatorUrl,
                options: nil
            )
        } catch {
            fatalError("Unable to Load Persistent Store. Error: \(error)")
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
