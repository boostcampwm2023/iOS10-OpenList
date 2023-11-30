//
//  AddCheckListItemViewModel.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import Combine

protocol AddCheckListItemViewModelable: ViewModelable
where Input == AddCheckListItemInput,
  State == AddCheckListItemState,
  Output == AnyPublisher<State, Never> { }

final class AddCheckListItemViewModel {
	private let categoryInfo: CategoryInfo
	private let categoryUseCase: CategoryUseCase
	
	init(
		categoryInfo: CategoryInfo,
		categoryUseCase: CategoryUseCase
	) {
		self.categoryInfo = categoryInfo
		self.categoryUseCase = categoryUseCase
	}
}

extension AddCheckListItemViewModel: AddCheckListItemViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany<Output>(
      viewDidLoad(input)
		).eraseToAnyPublisher()
  }
}

private extension AddCheckListItemViewModel {
	func viewDidLoad(_ input: Input) -> Output {
		if categoryInfo.mainCategory != nil &&
			categoryInfo.subCategory != nil &&
			categoryInfo.minorCategory != nil {
			return input.viewDidLoad
				.withUnretained(self)
				.flatMap { (owner, _) -> AnyPublisher<Result<[RecommendChecklistItem], Error>, Never> in
					let future = Future(asyncFunc: {
						await owner.categoryUseCase.fetchRecommendCheckList(with: owner.categoryInfo)
					})
					return future.eraseToAnyPublisher()
				}
				.withUnretained(self)
				.map { (owner, result) in
					switch result {
					case let .success(items):
						return .viewDidLoad(items, owner.categoryInfo)
					case let .failure(error):
						return .error(error)
					}
				}.eraseToAnyPublisher()
		}

		return input.viewDidLoad
			.withUnretained(self)
			.map { (owner, _) in
				return .viewDidLoad([], owner.categoryInfo)
			}.eraseToAnyPublisher()
	}
}
