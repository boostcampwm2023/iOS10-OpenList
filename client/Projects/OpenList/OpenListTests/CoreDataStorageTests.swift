//
//  CoreDataStorageTests.swift
//  OpenListTests
//
//  Created by wi_seong on 11/16/23.
//

import CoreData
import XCTest

final class CoreDataStorageTests: XCTestCase {
	private var coreDataStorage: CoreDataStorage!
	
	override func setUp() {
		super.setUp()
		self.coreDataStorage = CoreDataStorage()
	}
	
	func testSave() {
		coreDataStorage.performBackgroundTask { [weak self] context in
			guard let self = self else { return }
			do {
				let entity = CheckListResponseEntity(context: context)
				entity.id = UUID()
				entity.title = "checkList1"
				try context.save()
			} catch {
				XCTFail("Expected successful save, but got error: \(error)")
			}
		}
	}
	
	func testFetch() {
		coreDataStorage.performBackgroundTask { [weak self] context in
			guard let self = self else { return }
			do {
				let entity = CheckListResponseEntity(context: context)
				entity.id = UUID()
				entity.title = "checkList3"
				try context.save()
				
				let fetchRequest = CheckListResponseEntity.fetchRequest()
				
				let result = try context.fetch(fetchRequest).first
				print(result)
			} catch {
				XCTFail("Expected successful save, but got error: \(error)")
			}
		}
	}
}
