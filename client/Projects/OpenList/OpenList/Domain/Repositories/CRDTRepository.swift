//
//  CRDTRepository.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT
import Foundation

protocol CRDTRepository {
	@discardableResult
	func save(message: CRDTMessage) async throws -> CRDTMessage
	func send(id: UUID, isChecked: Bool, message: CRDTMessage) throws
	func documentDelete(id: UUID) throws
	func checkListStateUpdate(id: UUID, isChecked: Bool) throws
	func fetchCheckListItems(id: UUID) async throws -> [CRDTData]
}
