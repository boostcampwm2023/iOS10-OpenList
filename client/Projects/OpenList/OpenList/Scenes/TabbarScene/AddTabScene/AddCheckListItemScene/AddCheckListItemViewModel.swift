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
	private let persistenceUseCase: PersistenceUseCase
	
	init(
		categoryInfo: CategoryInfo,
		categoryUseCase: CategoryUseCase,
		persistenceUseCase: PersistenceUseCase
	) {
		self.categoryInfo = categoryInfo
		self.categoryUseCase = categoryUseCase
		self.persistenceUseCase = persistenceUseCase
	}
}

extension AddCheckListItemViewModel: AddCheckListItemViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany<Output>(
			configureHeader(input),
			viewDidLoad(input),
			nextButtonDidTapped(input)
		).eraseToAnyPublisher()
  }
}

private extension AddCheckListItemViewModel {
	func configureHeader(_ input: Input) -> Output {
		return input.configureHeaderView
			.withUnretained(self)
			.map { (owner, _) in
				return .configureHeader(owner.categoryInfo)
			}.eraseToAnyPublisher()
	}
	
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
				.map { (_, result) in
					switch result {
					case let .success(items):
						return .viewDidLoad(items)
					case let .failure(error):
						return .error(error)
					}
				}.eraseToAnyPublisher()
		}

		return input.viewDidLoad
			.map {
				return .viewDidLoad([])
			}.eraseToAnyPublisher()
	}
	
	func nextButtonDidTapped(_ input: Input) -> Output {
		return input.nextButtonDidTap
			.withUnretained(self)
			.flatMap { owner, items -> AnyPublisher<Bool, Never> in
				let future = Future(asyncFunc: {
					await owner.persistenceUseCase.saveCheckList(title: owner.categoryInfo.title, items: items)
				})
				return future.eraseToAnyPublisher()
			}
			.map { isSuccess -> State in
				return isSuccess ? .dismiss : .error(nil)
			}
			.eraseToAnyPublisher()
	}
}
