//
//  DefaultCategoryRepository.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import CustomNetwork
import Foundation

final class DefaultCategoryRepository {
	private let session: CustomSession
	
	init(session: CustomSession) {
		self.session = session
	}
}

extension DefaultCategoryRepository: CategoryRepository {
	enum Constant {
		static let baseUrl = "https://openlist.kro.kr/categories/"
		static let aiBaseUrl = "https://openlist.kro.kr/checklist-ai"
	}
	
	func fetchMainCategory() async throws -> [CategoryItem] {
		var builder = URLRequestBuilder(url: Constant.baseUrl + "main-categories")
		builder.addHeader(
			field: "Content-Type",
			value: "application/json"
		)
		let service = NetworkService(customSession: session, urlRequestBuilder: builder)
		let data = try await service.request()
		let mainCategoryResponseDTO = try JSONDecoder().decode([MainCategoryResponseDTO].self, from: data)
		let mainCategories = mainCategoryResponseDTO.map { CategoryItem(id: $0.id, name: $0.name) }
		return mainCategories
	}
	
	func fetchSubCategory(with mainCategory: CategoryItem) async throws -> [CategoryItem] {
		var builder = URLRequestBuilder(url: Constant.baseUrl + "\(mainCategory.id)" + "/sub-categories")
		builder.addHeader(
			field: "Content-Type",
			value: "application/json"
		)
		let service = NetworkService(customSession: session, urlRequestBuilder: builder)
		let data = try await service.request()
		let subCategoryResponseDTO = try JSONDecoder().decode([SubCategoryResponseDTO].self, from: data)
		let subCategories = subCategoryResponseDTO.map { CategoryItem(id: $0.id, name: $0.name) }
		return subCategories
	}
	
	func fetchMinorCategory(with mainCategory: CategoryItem, subCategory: CategoryItem) async throws -> [CategoryItem] {
		var builder = URLRequestBuilder(
			url: Constant.baseUrl + "\(mainCategory.id)" + "/sub-categories/" + "\(subCategory.id)" + "/minor-categories"
		)
		builder.addHeader(
			field: "Content-Type",
			value: "application/json"
		)
		let service = NetworkService(customSession: session, urlRequestBuilder: builder)
		let data = try await service.request()
		let minorCategoryResponseDTO = try JSONDecoder().decode([MinorCategoryResponseDTO].self, from: data)
		let minorCategories = minorCategoryResponseDTO.map { CategoryItem(id: $0.id, name: $0.name) }
		return minorCategories
	}
	
	func fetchRecommendCheckList(
		with categoryRequestDTO: CategoryInfoRequestDTO
	) async throws -> [RecommendChecklistItem] {
		var builder = URLRequestBuilder(url: Constant.aiBaseUrl)
		builder.addHeader(
			field: "Content-Type",
			value: "application/json"
		)
		let body = try JSONEncoder().encode(categoryRequestDTO)
		builder.setBody(body)
		builder.setMethod(.post)
		let service = NetworkService(customSession: session, urlRequestBuilder: builder)
		let data = try await service.request()
		let recommendChecklistResponseDTO = try JSONDecoder().decode(RecommendChecklistResponseDTO.self, from: data)
		let recommendChecklist = recommendChecklistResponseDTO.map { RecommendChecklistItem(id: $0.key, content: $0.value)}
		return recommendChecklist
	}
}
