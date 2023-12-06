//
//  PersistenceRepository.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

protocol CheckListRepository {
	func saveCheckList(id: UUID, title: String, items: [CheckListItem]) async -> Bool
	func fetchAllCheckList() async throws -> [CheckListTableItem]
	func fetchCheckList(id: UUID) async throws -> CheckList
	func removeCheckList(_ checkListId: UUID) -> Bool
	func appendCheckList(id: UUID, item: CheckListItem) async throws
	func updateCheckList(id: UUID, item: CheckListItem) async throws
	func removeCheckList(id: UUID, item: CheckListItem, orderBy: [UUID]) async throws
	func transfromToWith(id: UUID) async throws
	func fetchRecommendCheckList(id: Int) async throws -> [CheckList]
}
