//
//  DefaultWithCheckListRepository.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import CRDT
import CustomNetwork
import Foundation

final class DefaultWithCheckListRepository {
	private let session: CustomSession
	
	init(session: CustomSession = .init(interceptor: AccessTokenInterceptor())) {
		self.session = session
	}
}

struct RequestDTO: Encodable {
	let title: String
	let items: [CRDTMessageRequestDTO]
	let sharedChecklistId: UUID
}

extension DefaultWithCheckListRepository: WithCheckListRepository {
	enum Constant {
		static let baseUrl = "https://openlist.kro.kr/shared-checklists"
	}
	
	func changeToWithCheckList(
		title: String,
		items: [(editTextId: UUID, message: CRDTMessage)],
		sharedChecklistId: UUID
	) async -> Bool {
		var builder = URLRequestBuilder(url: Constant.baseUrl)
		builder.addHeader(field: "Content-Type", value: "application/json")
		builder.setMethod(.post)
		do {
			let crdtItems = items.map { (editTextId: UUID, message: CRDTMessage) -> CRDTMessageRequestDTO in
				return CRDTMessageRequestDTO(id: editTextId, data: message)
			}
			
			let reuqestDTO = RequestDTO(title: title, items: crdtItems, sharedChecklistId: sharedChecklistId)
			let body = try JSONEncoder().encode(reuqestDTO)
			builder.setBody(body)
			let service = NetworkService(customSession: session, urlRequestBuilder: builder)
			_ = try await service.request()
			return true
		} catch {
			return false
		}
	}
	
	func fetchAllSharedCheckList() async -> [WithCheckList] {
		var builder = URLRequestBuilder(url: Constant.baseUrl)
		builder.addHeader(field: "Content-Type", value: "application/json")
		builder.setMethod(.get)
		do {
			let service = NetworkService(customSession: session, urlRequestBuilder: builder)
			let data = try await service.request()
			let response = try JSONDecoder().decode([WithCheckListResponseDTO].self, from: data)
			return response.map {
				WithCheckList(
					title: $0.title,
					sharedCheckListId: $0.sharedCheckListId,
					users: $0.users.map {
						User(
							userId: $0.userId,
							email: $0.email,
							fullName: $0.fullName,
							nickname: $0.nickname,
							profileImage: $0.profileImage
						)
					}
				)
			}
		} catch {
			return []
		}
	}
}
