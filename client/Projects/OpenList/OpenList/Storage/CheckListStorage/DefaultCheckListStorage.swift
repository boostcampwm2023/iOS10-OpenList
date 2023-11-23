//
//  DefaultCheckListStorage.swift
//  OpenList
//
//  Created by 김영균 on 11/16/23.
//

import CoreData
import Foundation

final class DefaultCheckListStorage {
	private let coreDataStorage: CoreDataStorage
	
	init(coreDataStorage: CoreDataStorage = .shared) {
		self.coreDataStorage = coreDataStorage
	}
}

private extension DefaultCheckListStorage {
	func fetchAllCheckListFault() async throws -> [CheckListEntity] {
		return try await withCheckedThrowingContinuation { continuation in
			Task { [weak self] in
				guard let self else { return }
				let request: NSFetchRequest<CheckListEntity> = CheckListEntity.fetchRequest()
				let checkListFaults = try coreDataStorage.backgroundViewContext.fetch(request)
				continuation.resume(returning: checkListFaults)
			}
		}
	}
	
	func fetchEntity<T>(by id: NSManagedObjectID, type: T.Type) throws -> T {
		guard let entity = try coreDataStorage.viewContext.existingObject(with: id) as? T else {
			throw CoreDataStorageError.noData
		}
		return entity
	}
}

extension DefaultCheckListStorage: CheckListStorage {
	func fetchAllCheckList() async throws -> [LocalStorageCheckListResponseDTO] {
		return try await fetchAllCheckListFault()
			.map(\.objectID)
			.map { try fetchEntity(by: $0, type: CheckListEntity.self) }
			.compactMap(mapToLocalStorageCheckListResponseDTO(_:))
	}
	
	func saveCheckList(id: UUID, title: String) async throws {
		Task { [weak self] in
			guard let self else { return }
			let backgroundContext = coreDataStorage.backgroundViewContext
			let checkList = CheckListEntity(context: backgroundContext)
			checkList.makeInitialCheckListEntity(title: title)
			do {
				try backgroundContext.save()
				return
			} catch {
				throw CoreDataStorageError.saveError(error)
			}
		}
	}
}

private extension DefaultCheckListStorage {
	func mapToLocalStorageCheckListResponseDTO(
		_ entity: CheckListEntity
	) throws -> LocalStorageCheckListResponseDTO {
		guard
			let checklistId = entity.checklistId,
			let title = entity.title,
			let createdAt = entity.createdAt,
			let updatedAt = entity.updatedAt,
			let itemEntities = entity.itemId as? Set<CheckListItemEntity>
		else {
			throw CoreDataStorageError.unwrapError
		}
		
		let items = try itemEntities.compactMap(mapToLocalStorageCheckListItemResponseDTO(_:))
		
		return LocalStorageCheckListResponseDTO(
			checklistId: checklistId,
			createdAt: createdAt,
			updatedAt: updatedAt,
			title: title,
			progress: Int(entity.progress),
			items: items
		)
	}
	
	func mapToLocalStorageCheckListItemResponseDTO(
		_ entity: CheckListItemEntity
	) throws -> LocalStorageCheckListItemResponseDTO {
		guard
			let itemId = entity.itemId,
			let content = entity.content,
			let createdAt = entity.createdAt
		else {
			throw CoreDataStorageError.unwrapError
		}
		return LocalStorageCheckListItemResponseDTO(
			itemId: itemId,
			content: content,
			createdAt: createdAt,
			isChecked: entity.isChecked
		)
	}
}

private extension CheckListEntity {
	func makeInitialCheckListEntity(title: String) {
		self.checklistId = UUID()
		self.title = title
		self.progress = 0
		self.createdAt = .now
		self.updatedAt = .now
		self.itemId = nil
	}
}

private extension CheckListItemEntity {
	func makeInitialCheckListItemEntity(
		content: String,
		isChecked: Bool
	) {
		self.itemId = UUID()
		self.content = content
		self.isChecked = isChecked
		self.createdAt = .now
	}
}
