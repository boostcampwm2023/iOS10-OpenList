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
	private var minorCategoryTitle: String = ""
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
			.map { _ in
				let dummy = [
					"준비물", "핫플레이스", "맛집리스트", "시장투어", "쇼핑리스트", "커피리스트",
					"유적명소", "클럽추천", "이색여행지", "노포투어", "어르신투어"
				]
				return .load(dummy)
			}.eraseToAnyPublisher()
	}
	
	func nextButtonDidTap(_ input: Input) -> Output {
		return input.nextButtonDidTap
			.withUnretained(self)
			.map { (owner, _) in
				// useCase Login
				return .routeToNext(owner.minorCategoryTitle)
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
