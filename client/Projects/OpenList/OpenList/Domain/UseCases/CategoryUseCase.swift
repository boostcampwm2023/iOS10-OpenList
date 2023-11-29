//
//  CategoryUseCase.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

protocol CategoryUseCase {
	func fetchMainCategory() async -> Result<[CategoryItem], Error>
	func fetchSubCategory(with mainCategory: CategoryItem) async -> Result<[CategoryItem], Error>
	func fetchMinorCategory(with mainCategory: CategoryItem, subCategory: CategoryItem) async -> Result<[CategoryItem], Error>
	func fetchRecommendCheckList(with categoryInfo: CategoryInfo) async -> Result<[RecommendChecklistItem], Error>
}

final class DefaultCategoryUseCase {
	private let categoryRepository: CategoryRepository
	
	init(categoryRepository: CategoryRepository) {
		self.categoryRepository = categoryRepository
	}
}

extension DefaultCategoryUseCase: CategoryUseCase {
	func fetchMainCategory() async -> Result<[CategoryItem], Error> {
		do {
			let items = try await categoryRepository.fetchMainCategory()
			return .success(items)
		} catch {
			return .failure(error)
		}
	}
	
	func fetchSubCategory(with mainCategory: CategoryItem) async -> Result<[CategoryItem], Error> {
		do {
			let items = try await categoryRepository.fetchSubCategory(with: mainCategory)
			return .success(items)
		} catch {
			return .failure(error)
		}
	}
	
	func fetchMinorCategory(with mainCategory: CategoryItem, subCategory: CategoryItem) async -> Result<[CategoryItem], Error> {
		do {
			let items = try await categoryRepository.fetchMinorCategory(with: mainCategory, subCategory: subCategory)
			return .success(items)
		} catch {
			return .failure(error)
		}
	}
	
	func fetchRecommendCheckList(with categoryInfo: CategoryInfo) async -> Result<[RecommendChecklistItem], Error> {
		let categoryRequestDTO = CategoryInfoRequestDTO(
			mainCategory: categoryInfo.mainCategory!,
			subCategory: categoryInfo.subCategory!,
			minorCategory: categoryInfo.minorCategory!
		)
		do {
			let items = try await categoryRepository.fetchRecommendCheckList(with: categoryRequestDTO)
			return .success(items)
		} catch {
			return .failure(error)
		}
	}
}
