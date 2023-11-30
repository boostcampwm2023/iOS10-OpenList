//
//  DefaultFolderRepository.swift
//  OpenList
//
//  Created by 김영균 on 11/29/23.
//

import CustomNetwork
import Foundation
	
final class DefaultFolderRepository {
	private let session: CustomSession
	
	init(session: CustomSession = CustomSession(configuration: .default, interceptor: AccessTokenInterceptor())) {
		self.session = session
	}
}

extension DefaultFolderRepository: FolderRepository {
	enum Constant {
		static let baseUrl = "https://openlist.kro.kr/folders"
	}
	
	func fetchAllFolders() async throws -> [CheckListFolderItem] {
		var builder = URLRequestBuilder(url: Constant.baseUrl)
		builder.addHeader(
			field: "Content-Type",
			value: "application/json"
		)
		let service = NetworkService(customSession: session, urlRequestBuilder: builder)
		let data = try await service.getData()
		let folderResponseDTO = try JSONDecoder().decode([FolderResponseDTO].self, from: data)
		let folders = folderResponseDTO.map { CheckListFolderItem(folderId: $0.folderId, title: $0.title) }
		return folders
	}
}
