//
//  DetailCheckListUseCase.swift
//  OpenList
//
//  Created by wi_seong on 11/27/23.
//

import Foundation

protocol DetailCheckListUseCase {
	func fetchCheckList(id: UUID) async -> CheckList?
}

final class DefaultDetailCheckListUseCase {
	private let checkListRepository: CheckListRepository
	
	init(checkListRepository: CheckListRepository) {
		self.checkListRepository = checkListRepository
	}
}

extension DefaultDetailCheckListUseCase: DetailCheckListUseCase {
	func fetchCheckList(id: UUID) async -> CheckList? {
		do {
			let item = try await checkListRepository.fetchCheckList(id: id)
			return item
		} catch {
			return nil
		}
	}
}
