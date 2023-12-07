//
//  DefaultPersistenceRepository.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import CustomNetwork
import Foundation

final class DefaultCheckListRepository {
	private let checkListStorage: PrivateCheckListStorage
	private let session: CustomSession
	
	init(checkListStorage: PrivateCheckListStorage, session: CustomSession) {
		self.checkListStorage = checkListStorage
		self.session = session
	}
}

extension DefaultCheckListRepository: CheckListRepository {
	// 체크리스트를 삭제합니다.
	func removeCheckList(_ checklistId: UUID) -> Bool {
		do {
			try checkListStorage.removeCheckList(id: checklistId)
			return true
		} catch {
			return false
		}
	}
	
	func saveCheckList(id: UUID, title: String, items: [CheckListItem]) async -> Bool {
		do {
			try await checkListStorage.saveCheckList(id: id, title: title, items: items)
			return true
		} catch {
			return false
		}
	}
	
	func fetchAllCheckList() async throws -> [CheckListTableItem] {
		let result = try await checkListStorage.fetchAllCheckList()
		return result.map {
			let achievementRate = ($0.items.isEmpty ? 0 : Double($0.progress) / Double($0.items.count))
			return CheckListTableItem(
				id: $0.checklistId,
				title: $0.title,
				achievementRate: achievementRate
			)
		}
	}
	
	func fetchCheckList(id: UUID) async throws -> CheckList {
		let result = try await checkListStorage.fetchCheckList(id: id)
		return .init(
			id: result.checklistId,
			title: result.title,
			createdAt: result.createdAt,
			updatedAt: result.updatedAt,
			progress: result.progress,
			orderBy: result.orderBy,
			items: result.items.map {
				.init(
					itemId: $0.itemId,
					title: $0.content,
					isChecked: $0.isChecked
				)
			}
		)
	}
	
	func appendCheckList(id: UUID, item: CheckListItem) async throws {
		return try await checkListStorage.appendCheckListItem(id: id, item: item)
	}
	
	func updateCheckList(id: UUID, item: CheckListItem) async throws {
		return try await checkListStorage.updateCheckListItem(id: id, item: item)
	}
	
	func removeCheckList(id: UUID, item: CheckListItem, orderBy: [UUID]) async throws {
		return try await checkListStorage.removeCheckListItem(id: id, item: item, orderBy: orderBy)
	}
	
	func transfromToWith(id: UUID) async throws {
		return try await checkListStorage.transfromToWith(id: id)
	}
	
	func fetchFeedCheckList(by cateogryName: String) async throws -> [FeedCheckList] {
		let urlString = "https://openlist.kro.kr/feeds/category?category=\(cateogryName)"
		guard let koreanEncodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
		else { return [] }
		var builder = URLRequestBuilder(url: koreanEncodedString)
		builder.addHeader(field: "Content-Type", value: "application/json")
		builder.setMethod(.get)
		let service = NetworkService(customSession: session, urlRequestBuilder: builder)
		let data = try await service.request()
		let feedCheckListResponseDTO = try JSONDecoder().decode([FeedCheckListResponseDTO].self, from: data)
		return feedCheckListResponseDTO.map {
			FeedCheckList(
				createdAt: $0.createdAt,
				title: $0.title,
				items: $0.items.map { FeedCheckListItem(isChecked: $0.isChecked, value: $0.value) },
				feedId: $0.feedId,
				likeCount: $0.likeCount,
				downloadCount: $0.downloadCount
			)
		}
	}
}
