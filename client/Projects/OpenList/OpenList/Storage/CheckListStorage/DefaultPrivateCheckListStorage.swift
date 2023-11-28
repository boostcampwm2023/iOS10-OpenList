//
//  DefaultPrivateCheckListStorage.swift
//  OpenList
//
//  Created by 김영균 on 11/16/23.
//

import CoreData
import Foundation

final class DefaultPrivateCheckListStorage {
	private let coreDataStorage: CoreDataStorage
	
	init(coreDataStorage: CoreDataStorage = .shared) {
		self.coreDataStorage = coreDataStorage
	}
}

private extension DefaultPrivateCheckListStorage {
	func fetchAllCheckListFault(
		context: NSManagedObjectContext
	) async throws -> [PrivateCheckListEntity] {
		return try await withCheckedThrowingContinuation { continuation in
			Task {
				let request: NSFetchRequest<PrivateCheckListEntity> = PrivateCheckListEntity.fetchRequest()
				let checkListFaults = try context.fetch(request)
				continuation.resume(returning: checkListFaults)
			}
		}
	}
	
	func fetchCheckListFault(
		id: UUID,
		context: NSManagedObjectContext
	) async throws -> [PrivateCheckListEntity] {
		return try await withCheckedThrowingContinuation { continuation in
			Task {
				let request: NSFetchRequest<PrivateCheckListEntity> = PrivateCheckListEntity.fetchRequest()
				request.predicate = NSPredicate(
					format: "%K == %@",
					#keyPath(PrivateCheckListEntity.checklistId),
					id as CVarArg
				)
				let checkListFaults = try context.fetch(request)
				continuation.resume(returning: checkListFaults)
			}
		}
	}
	
	func fetchEntity<T>(
		by id: NSManagedObjectID,
		context: NSManagedObjectContext,
		type: T.Type
	) throws -> T {
		guard let entity = try coreDataStorage.viewContext.existingObject(with: id) as? T else {
			throw CoreDataStorageError.noData
		}
		return entity
	}
}

extension DefaultPrivateCheckListStorage: PrivateCheckListStorage {
	func fetchAllCheckList() async throws -> [PrivateCheckListResponseDTO] {
		let context = coreDataStorage.backgroundViewContext
		return try await fetchAllCheckListFault(context: context)
			.map(\.objectID)
			.map { try fetchEntity(by: $0, context: context, type: PrivateCheckListEntity.self) }
			.compactMap(mapToLocalStorageCheckListResponseDTO(_:))
	}
	
	func fetchCheckList(id: UUID) async throws -> PrivateCheckListResponseDTO {
		let context = coreDataStorage.backgroundViewContext
		let response = try await fetchCheckListFault(id: id, context: context)
			.map(\.objectID)
			.map { try fetchEntity(by: $0, context: context, type: PrivateCheckListEntity.self) }
			.compactMap(mapToLocalStorageCheckListResponseDTO(_:))
			.first
		guard let response else {
			throw CoreDataStorageError.noData
		}
		return response
	}
	
	func saveCheckList(id: UUID, title: String) async throws {
		Task { [weak self] in
			guard let self else { return }
			let backgroundContext = coreDataStorage.backgroundViewContext
			let checkList = PrivateCheckListEntity(context: backgroundContext)
			checkList.makeInitialCheckListEntity(title: title)
			do {
				try backgroundContext.save()
				return
			} catch {
				throw CoreDataStorageError.saveError(error)
			}
		}
	}
	
	func appendCheckListItem(id: UUID, item: CheckListItem) async throws {
		Task { [weak self] in
			guard let self else { return }
			let context = coreDataStorage.backgroundViewContext
			guard let checkListFaults = try await fetchCheckListFault(id: id, context: context).first else {
				throw CoreDataStorageError.noData
			}
			
			let itemEntity = PrivateCheckListItemEntity(context: context)
			itemEntity.makeInitialCheckListItemEntity(
				itemId: item.id,
				index: item.index,
				content: item.title,
				isChecked: item.isChecked
			)
			checkListFaults.addToItemId(itemEntity)
			try context.save()
			return
		}
	}
	
	func updateCheckListItem(id: UUID, item: CheckListItem) async throws -> PrivateCheckListResponseDTO {
		fatalError()
	}
	
	func removeCheckListItem(id: UUID, item: CheckListItem) async throws -> PrivateCheckListResponseDTO {
		fatalError()
	}
}

private extension DefaultPrivateCheckListStorage {
	func mapToLocalStorageCheckListResponseDTO(
		_ entity: PrivateCheckListEntity
	) throws -> PrivateCheckListResponseDTO {
		guard
			let checklistId = entity.checklistId,
			let title = entity.title,
			let createdAt = entity.createdAt,
			let updatedAt = entity.updatedAt,
			let itemEntities = entity.itemId as? Set<PrivateCheckListItemEntity>
		else {
			throw CoreDataStorageError.unwrapError
		}
		
		let items = try itemEntities.compactMap(mapToCheckListItemResponseDTO(_:))
		
		return PrivateCheckListResponseDTO(
			checklistId: checklistId,
			createdAt: createdAt,
			updatedAt: updatedAt,
			title: title,
			progress: Int(entity.progress),
			items: items
		)
	}
	
	func mapToCheckListItemResponseDTO(
		_ entity: PrivateCheckListItemEntity
	) throws -> PrivateCheckListItemResponseDTO {
		guard
			let itemId = entity.itemId,
			let content = entity.content,
			let createdAt = entity.createdAt
		else {
			throw CoreDataStorageError.unwrapError
		}
		return PrivateCheckListItemResponseDTO(
			itemId: itemId,
			content: content,
			createdAt: createdAt,
			isChecked: entity.isChecked,
			index: entity.index
		)
	}
}

private extension PrivateCheckListEntity {
	func makeInitialCheckListEntity(title: String) {
		self.checklistId = UUID()
		self.title = title
		self.progress = 0
		self.createdAt = .now
		self.updatedAt = .now
		self.itemId = nil
	}
}

private extension PrivateCheckListItemEntity {
	func makeInitialCheckListItemEntity(
		itemId: UUID,
		index: Int32,
		content: String,
		isChecked: Bool
	) {
		self.itemId = itemId
		self.index = index
		self.content = content
		self.isChecked = isChecked
		self.createdAt = .now
	}
}

extension NSManagedObject {
	func addObject(value: NSManagedObject, forKey key: String) {
		let items = self.mutableSetValue(forKey: key)
		items.add(value)
	}
	
	func removeObject(value: NSManagedObject, forKey key: String) {
		let items = self.mutableSetValue(forKey: key)
		items.remove(value)
	}
}
