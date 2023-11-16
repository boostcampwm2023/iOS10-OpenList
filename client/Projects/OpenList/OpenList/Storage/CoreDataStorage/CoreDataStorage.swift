//
//  CoreDataStorage.swift
//  OpenList
//
//  Created by wi_seong on 11/16/23.
//

import CoreData

enum CoreDataStorageError: Error {
	case readError(Error)
	case saveError(Error)
	case deleteError(Error)
	case selfCapturingError
	case noData
}

final class CoreDataStorage {
	static let shared = CoreDataStorage()
	
	private init() {}
	
	var viewContext: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	var backgroundViewContext: NSManagedObjectContext {
		let newBackgroundContext = persistentContainer.newBackgroundContext()
		newBackgroundContext.automaticallyMergesChangesFromParent = true
		return newBackgroundContext
	}
	
	// MARK: - Core Data stack
	private lazy var persistentContainer: NSPersistentContainer = {
		guard let modelURL = Bundle.main.url(forResource: "CoreDataStorage", withExtension: "momd"),
			let mom = NSManagedObjectModel(contentsOf: modelURL)
		else {
			fatalError("Unable to located Core Data model")
		}
		let container = NSPersistentContainer(name: "Name", managedObjectModel: mom)
		container.loadPersistentStores { _, error in
			if let error = error as NSError? {
				debugPrint("CoreDataStorage Unresolved error \(error), \(error.userInfo)")
			}
		}
		return container
	}()
	
	// MARK: - Core Data Saving support
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Log to Crashlytics
				debugPrint("CoreDataStorage Unresolved error \(error), \((error as NSError).userInfo)")
			}
		}
	}
	
	func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
		persistentContainer.performBackgroundTask(block)
	}
}
