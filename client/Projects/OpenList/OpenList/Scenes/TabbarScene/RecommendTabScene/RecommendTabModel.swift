//
//  RecommendTabModel.swift
//  OpenList
//
//  Created by 김영균 on 12/4/23.
//

import Combine

protocol RecommendTabModelable: ViewModelable
where Input == RecommendTabInput,
	State == RecommendTabState,
	Output == AnyPublisher<State, Never> { }

final class RecommendTabModel {
	private let categoryUseCase: CategoryUseCase
	private let recommendCheckListUseCase: RecommendCheckListUseCase
	
	init(
		categoryUseCase: CategoryUseCase,
		recommendCheckListUseCase: RecommendCheckListUseCase
	) {
		self.categoryUseCase = categoryUseCase
		self.recommendCheckListUseCase = recommendCheckListUseCase
	}
}

extension RecommendTabModel: RecommendTabModelable {
	func transform(_ input: Input) -> Output {
		return Publishers.MergeMany<Output>(
			fetchRecommendCategory(input),
			fetchRecommendCheckList(input)
		).eraseToAnyPublisher()
	}
}

private extension RecommendTabModel {
	func fetchRecommendCategory(_ input: Input) -> Output {
		return input.viewWillAppear
			.flatMap { [weak self] in
				LoadingIndicator.showLoading()
				return Future(asyncFunc: { await self?.categoryUseCase.fetchMainCategory() })
					.eraseToAnyPublisher()
			}
			.map { result in
				switch result {
				case let .success(cateogires):
					return .reloadRecommendCategory(cateogires)
					
				case let .failure(error):
					return .error(error)
					
				case .none:
					return .reloadRecommendCategory([])
				}
			}.eraseToAnyPublisher()
	}
	
	func fetchRecommendCheckList(_ input: Input) -> Output {
		return input.fetchRecommendCheckList
			.flatMap { [weak self] categoryName in
				LoadingIndicator.showLoading()
				return Future(asyncFunc: { await self?.recommendCheckListUseCase.fetchFeedCheckList(by: categoryName) })
					.eraseToAnyPublisher()
			}
			.map { result in
				switch result {
				case let .success(checkList):
					return .reloadRecommendCheckList(checkList)
					
				case let .failure(error):
					return .error(error)
					
				case .none:
					return .reloadRecommendCategory([])
				}
			}
			.eraseToAnyPublisher()
	}
}
