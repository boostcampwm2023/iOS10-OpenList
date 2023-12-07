//
//  SharedCheckListRepository.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import CRDT
import Foundation

protocol WithCheckListRepository {
	func changeToWithCheckList(
		title: String,
		items: [(editTextId: UUID, message: CRDTMessage)],
		sharedChecklistId: UUID
	) async -> Bool
	func fetchAllSharedCheckList() async -> [WithCheckList]
	func removeCheckList(_ checkListId: UUID) async throws -> Bool
}
