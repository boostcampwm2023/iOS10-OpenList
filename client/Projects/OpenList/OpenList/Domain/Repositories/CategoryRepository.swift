//
//  CategoryRepository.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

protocol CategoryRepository {
	func fetchMainCategory() async throws -> [CategoryItem]
	func fetchSubCategory(with mainCategory: CategoryItem) async throws -> [CategoryItem]
	func fetchMinorCategory(with mainCategory: CategoryItem, subCategory: CategoryItem) async throws -> [CategoryItem]
	func fetchRecommendCheckList(with categoryRequestDTO: CategoryInfoRequestDTO) async throws -> [RecommendChecklistItem]
}
