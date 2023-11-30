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
	
	func fetchCheckListItemFault(
		id: UUID,
		context: NSManagedObjectContext
	) async throws -> [PrivateCheckListItemEntity] {
		return try await withCheckedThrowingContinuation { continuation in
			Task {
				let request: NSFetchRequest<PrivateCheckListItemEntity> = PrivateCheckListItemEntity.fetchRequest()
				request.predicate = NSPredicate(
					format: "%K == %@",
					#keyPath(PrivateCheckListItemEntity.itemId),
					id as CVarArg
				)
				let checkListItemFaults = try context.fetch(request)
				continuation.resume(returning: checkListItemFaults)
			}
		}
	}
	
	func fetchEntity<T>(
		by id: NSManagedObjectID,
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
			.map { try fetchEntity(by: $0, type: PrivateCheckListEntity.self) }
			.compactMap(mapToLocalStorageCheckListResponseDTO(_:))
	}
	
	func fetchCheckList(id: UUID) async throws -> PrivateCheckListResponseDTO {
		let context = coreDataStorage.backgroundViewContext
		let response = try await fetchCheckListFault(id: id, context: context)
			.map(\.objectID)
			.map { try fetchEntity(by: $0, type: PrivateCheckListEntity.self) }
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
	
	// 체크리스트를 삭제합니다.
	func removeCheckList(id: UUID) throws {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PrivateCheckListEntity")
		fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(PrivateCheckListEntity.checklistId), id as CVarArg)
		do {
			let entities = try coreDataStorage.viewContext.fetch(fetchRequest)
			guard let checkList = entities.first as? NSManagedObject else { return }
			coreDataStorage.viewContext.delete(checkList)
			try coreDataStorage.viewContext.save()
		} catch {
			throw CoreDataStorageError.saveError(error)
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
				content: item.title,
				isChecked: item.isChecked
			)
			checkListFaults.addToItemId(itemEntity)
			try checkListFaults.appendOrderBy(item.id)
			try context.save()
			return
		}
	}
	
	func updateCheckListItem(id: UUID, item: CheckListItem) async throws {
		Task { [weak self] in
			guard let self else { return }
			let context = coreDataStorage.backgroundViewContext
			guard let checkListItemFaults = try await fetchCheckListItemFault(id: item.id, context: context).first else {
				throw CoreDataStorageError.noData
			}
			if checkListItemFaults.isChecked == item.isChecked {
				checkListItemFaults.update(content: item.title)
			} else {
				guard let checkListFaults = try await fetchCheckListFault(id: id, context: context).first else {
					throw CoreDataStorageError.noData
				}
				checkListFaults.update(item.isChecked)
				checkListItemFaults.update(isChecked: item.isChecked)
			}
			try context.save()
			return
		}
	}
	
	func removeCheckListItem(id: UUID, item: CheckListItem, orderBy: [UUID]) async throws {
		Task { [weak self] in
			guard let self else { return }
			let context = coreDataStorage.backgroundViewContext
			guard let checkListFaults = try await fetchCheckListFault(id: id, context: context).first else {
				throw CoreDataStorageError.noData
			}
			guard let checkListItemFaults = try await fetchCheckListItemFault(id: item.id, context: context).first else {
				throw CoreDataStorageError.noData
			}
			
			checkListFaults.removeFromItemId(checkListItemFaults)
			checkListFaults.orderBy = orderBy
			if item.isChecked {
				checkListFaults.update(false)
			}
			context.delete(checkListItemFaults)
			try context.save()
			return
		}
	}
	
	func transfromToWith(id: UUID) async throws {
		throw CoreDataStorageError.noData
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
			let orderBy = entity.orderBy,
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
			orderBy: orderBy,
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
			isChecked: entity.isChecked
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
		self.orderBy = []
	}
	
	func appendOrderBy(_ id: UUID) throws {
		guard let orderBy = self.orderBy else {
			throw CoreDataStorageError.unwrapError
		}
		self.orderBy = orderBy + [id]
	}
	
	func update(_ positive: Bool) {
		let progress = (positive ? progress + 1 : progress - 1)
		self.progress = max(0, progress)
	}
}

private extension PrivateCheckListItemEntity {
	func makeInitialCheckListItemEntity(
		itemId: UUID,
		content: String,
		isChecked: Bool
	) {
		self.itemId = itemId
		self.content = content
		self.isChecked = isChecked
		self.createdAt = .now
	}
	
	func update(content: String) {
		self.content = content
	}
	
	func update(isChecked: Bool) {
		self.isChecked = isChecked
	}
}
