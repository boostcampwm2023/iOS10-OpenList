//
//  MinorCategoryViewModel.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Combine
import Foundation

protocol MinorCategoryViewModelable: ViewModelable
where Input == MinorCategoryInput,
	State == MinorCategoryState,
	Output == AnyPublisher<State, Never> { }

final class MinorCategoryViewModel {
	private let title: String
	private let mainCategoryItem: CategoryItem
	private let subCategoryItem: CategoryItem
	private let categoryUseCase: CategoryUseCase
	private var minorCategoryTitle: String = ""
	
	init(
		title: String,
		mainCategory: CategoryItem,
		subCategory: CategoryItem,
		categoryUseCase: CategoryUseCase
	) {
		self.title = title
		self.mainCategoryItem = mainCategory
		self.subCategoryItem = subCategory
		self.categoryUseCase = categoryUseCase
	}
}

extension MinorCategoryViewModel: MinorCategoryViewModelable {
  func transform(_ input: Input) -> Output {
		let viewLoad = viewLoad(input)
		let nextButtonDidTap = nextButtonDidTap(input)
		let collectionViewCellDidSelect = collectionViewCellDidSelect(input)
		return Publishers.MergeMany([
			viewLoad,
			nextButtonDidTap,
			collectionViewCellDidSelect
		]).eraseToAnyPublisher()
  }
}

private extension MinorCategoryViewModel {
	func viewLoad(_ input: Input) -> Output {
		return input.viewLoad
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<Result<[CategoryItem], Error>, Never> in
				let future = Future(asyncFunc: {
					await owner.categoryUseCase.fetchMinorCategory(
						with: owner.mainCategoryItem,
						subCategory: owner.subCategoryItem
					)
				})
				return future.eraseToAnyPublisher()
			}
			.map { result in
				switch result {
				case let .success(items):
					return .load(items)
				case let .failure(error):
					return .error(error)
				}
			}.eraseToAnyPublisher()
	}
	
	func nextButtonDidTap(_ input: Input) -> Output {
		return input.nextButtonDidTap
			.withUnretained(self)
			.map { (owner, _) in
				let categoryInfo = CategoryInfo(
					title: owner.title,
					mainCategory: owner.mainCategoryItem.name,
					subCategory: owner.subCategoryItem.name,
					minorCategory: owner.minorCategoryTitle
				)
				return .routeToNext(categoryInfo)
			}.eraseToAnyPublisher()
	}
	
	func collectionViewCellDidSelect(_ input: Input) -> Output {
		input.collectionViewCellDidSelect
			.withUnretained(self)
			.map { (owner, text) in
				owner.minorCategoryTitle = text
				return .none
			}.eraseToAnyPublisher()
	}
}
