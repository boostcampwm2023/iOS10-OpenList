//
//  MainCategoryViewModel.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Combine

protocol MainCategoryViewModelable: ViewModelable
where Input == MainCategoryInput,
State == MainCategoryState,
Output == AnyPublisher<State, Never> { }

final class MainCategoryViewModel {
	private var title: String
	private var mainCategoryItems: [String: CategoryItem] = [:]
	private var categoryText: String = ""
	private let categoryUseCase: CategoryUseCase
	
	init(
		title: String,
		categoryUseCase: CategoryUseCase
	) {
		self.title = title
		self.categoryUseCase = categoryUseCase
	}
}

extension MainCategoryViewModel: MainCategoryViewModelable {
	func transform(_ input: Input) -> Output {
		let viewLoad = viewLoad(input)
		let nextButtonDidTap = nextButtonDidTap(input)
		let skipButtonDidTap = skipButtonDidTap(input)
		let collectionViewCellDidSelect = collectionViewCellDidSelect(input)
		return Publishers.MergeMany(
			viewLoad,
			nextButtonDidTap,
			skipButtonDidTap,
			collectionViewCellDidSelect
		).eraseToAnyPublisher()
	}
}

private extension MainCategoryViewModel {
	func viewLoad(_ input: Input) -> Output {
		return input.viewLoad
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<Result<[CategoryItem], Error>, Never> in
				let future = Future(asyncFunc: {
					await owner.categoryUseCase.fetchMainCategory()
				})
				return future.eraseToAnyPublisher()
			}
			.map { [weak self] result in
				switch result {
				case let .success(items):
					self?.mainCategoryItems = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0) })
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
				guard let categoryItem = owner.mainCategoryItems[owner.categoryText] else { return .none }
				return .routeToNext(owner.title, categoryItem)
			}.eraseToAnyPublisher()
	}
	
	func collectionViewCellDidSelect(_ input: Input) -> Output {
		return input.collectionViewCellDidSelect
			.withUnretained(self)
			.map { (owner, text) in
				owner.categoryText = text
				return .none
			}.eraseToAnyPublisher()
	}
	
	func skipButtonDidTap(_ input: Input) -> Output {
		return input.skipButtonDidTap
			.withUnretained(self)
			.map { (owner, _) in
				let categoryInfo = CategoryInfo(title: owner.title)
				return .routeToLast(categoryInfo)
			}.eraseToAnyPublisher()
	}
}
