//
//  DefaultCategoryRepository.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import CustomNetwork
import Foundation

enum CategoryNilError: Error {
	case categoryNilError
}

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
		let mainCategories = mainCategoryResponseDTO.map { CategoryItem(name: $0.name) }
		return mainCategories
	}
	
	func fetchSubCategory(with mainCategory: CategoryItem) async throws -> [CategoryItem] {
		var builder = URLRequestBuilder(url: Constant.baseUrl + "sub-categories")
		builder.addQuery(query: ["mainCategory": mainCategory.name])
		builder.setMethod(.get)
		builder.addHeader(
			field: "Content-Type",
			value: "application/json"
		)
		let service = NetworkService(customSession: session, urlRequestBuilder: builder)
		let data = try await service.request()
		let subCategoryResponseDTO = try JSONDecoder().decode([SubCategoryResponseDTO].self, from: data)
		let subCategories = subCategoryResponseDTO.map { CategoryItem(name: $0.name) }
		return subCategories
	}
	
	func fetchMinorCategory(with mainCategory: CategoryItem, subCategory: CategoryItem) async throws -> [CategoryItem] {
		var builder = URLRequestBuilder(url: Constant.baseUrl + "minor-categories")
		builder.setMethod(.get)
		builder.addQuery(query: [
			"mainCategory": mainCategory.name,
			"subCategory": subCategory.name
		])
		builder.addHeader(
			field: "Content-Type",
			value: "application/json"
		)
		let service = NetworkService(customSession: session, urlRequestBuilder: builder)
		let data = try await service.request()
		let minorCategoryResponseDTO = try JSONDecoder().decode([MinorCategoryResponseDTO].self, from: data)
		let minorCategories = minorCategoryResponseDTO.map { CategoryItem(name: $0.name) }
		return minorCategories
	}
	
	func fetchRecommendCheckList(
		categoryInfo: CategoryInfo
	) async throws -> [RecommendChecklistItem] {
		var builder = URLRequestBuilder(url: Constant.aiBaseUrl)
		builder.addHeader(
			field: "Content-Type",
			value: "application/json"
		)
		
		guard
			let mainCategory = categoryInfo.mainCategory,
			let subCategory = categoryInfo.subCategory,
			let minorCategory = categoryInfo.minorCategory
		else { throw CategoryNilError.categoryNilError }
		
		let categoryRequestDTO = CategoryInfoRequestDTO(
			mainCategory: mainCategory,
			subCategory: subCategory,
			minorCategory: minorCategory
		)
		
		let body = try JSONEncoder().encode(categoryRequestDTO)
		builder.setBody(body)
		builder.setMethod(.post)
		let service = NetworkService(customSession: session, urlRequestBuilder: builder)
		let data = try await service.request()
		let recommendChecklistResponseDTO = try JSONDecoder().decode([RecommendChecklistResponseDTO].self, from: data)
		let recommendChecklist = recommendChecklistResponseDTO.map { RecommendChecklistItem(id: $0.id, content: $0.content)}
		return recommendChecklist
	}
}
