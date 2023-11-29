//
//  FolderRepository.swift
//  OpenList
//
//  Created by 김영균 on 11/29/23.
//

import Foundation

protocol FolderRepository {
	func fetchAllFolders() async throws -> [CheckListFolderItem]
}
