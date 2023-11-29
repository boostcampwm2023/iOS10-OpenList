//
//  PrivateCheckListUseCase.swift
//  OpenList
//
//  Created by 김영균 on 11/29/23.
//

import Foundation

protocol PrivateCheckListUseCase {
	func fetchAllFolders() async -> Result<[CheckListFolderItem], Error>
}

final class DefaultPrivateCheckListUseCase {
	private let folderRepository: FolderRepository
	
	init(folderRepository: FolderRepository) {
		self.folderRepository = folderRepository
	}
}

extension DefaultPrivateCheckListUseCase: PrivateCheckListUseCase {
	func fetchAllFolders() async -> Result<[CheckListFolderItem], Error> {
		do {
			let folders = try await folderRepository.fetchAllFolders()
			return .success(folders)
		} catch {
			return .failure(error)
		}
	}
}
