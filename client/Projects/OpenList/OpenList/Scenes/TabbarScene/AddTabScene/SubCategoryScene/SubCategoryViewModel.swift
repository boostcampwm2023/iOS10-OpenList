//
//  SubCategoryViewModel.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Combine

protocol SubCategoryViewModelable: ViewModelable
where Input == SubCategoryInput,
State == SubCategoryState,
Output == AnyPublisher<State, Never> { }

final class SubCategoryViewModel {
	private let title: String
	private var mainCategoryItem: CategoryItem
	private var subCategoryTitle: String = ""
	private var subCategoryItems: [String: CategoryItem] = [:]
	private let categoryUseCase: CategoryUseCase
	
	init(
		title: String,
		mainCategoryItem: CategoryItem,
		categoryUseCase: CategoryUseCase
	) {
		self.title = title
		self.mainCategoryItem = mainCategoryItem
		self.categoryUseCase = categoryUseCase
	}
}

extension SubCategoryViewModel: SubCategoryViewModelable {
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

private extension SubCategoryViewModel {
	func viewLoad(_ input: Input) -> Output {
		return input.viewLoad
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<Result<[CategoryItem], Error>, Never> in
				let future = Future(asyncFunc: {
					await owner.categoryUseCase.fetchSubCategory(with: owner.mainCategoryItem)
				})
				return future.eraseToAnyPublisher()
			}
			.map { [weak self] result in
				switch result {
				case let .success(items):
					self?.subCategoryItems = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0) })
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
				guard let subCategoryItem = owner.subCategoryItems[owner.subCategoryTitle] else { return .none }
				return .routeToNext(owner.title, owner.mainCategoryItem, subCategoryItem)
			}.eraseToAnyPublisher()
	}
	
	func collectionViewCellDidSelect(_ input: Input) -> Output {
		input.collectionViewCellDidSelect
			.withUnretained(self)
			.map { (owner, text) in
				owner.subCategoryTitle = text
				return .none
			}.eraseToAnyPublisher()
	}
}
