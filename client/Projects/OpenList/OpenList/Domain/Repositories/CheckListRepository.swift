//
//  PersistenceRepository.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

protocol CheckListRepository {
	func saveCheckList(id: UUID, title: String) async -> Bool
	func fetchAllCheckList() async throws -> [CheckListTableItem]
	func fetchCheckList(id: UUID) async throws -> CheckList
	func appendCheckList(id: UUID, item: CheckListItem) async throws
	func updateCheckList(item: CheckListItem) async throws
	func removeCheckList(id: UUID, item: CheckListItem, orderBy: [UUID]) async throws
}
