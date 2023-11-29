//
//  MajorCategoryViewModel.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Combine

protocol MajorCategoryViewModelable: ViewModelable
where Input == MajorCategoryInput,
State == MajorCategoryState,
Output == AnyPublisher<State, Never> { }

final class MajorCategoryViewModel {
	private var title: String
	private var categoryText: String = ""
	
	init(title: String) {
		self.title = title
	}
}

extension MajorCategoryViewModel: MajorCategoryViewModelable {
	func transform(_ input: Input) -> Output {
		let viewLoad = viewLoad(input)
		let nextButtonDidTap = nextButtonDidTap(input)
		let collectionViewCellDidSelect = collectionViewCellDidSelect(input)
		return Publishers.MergeMany(
			viewLoad,
			nextButtonDidTap,
			collectionViewCellDidSelect
		).eraseToAnyPublisher()
	}
}

private extension MajorCategoryViewModel {
	func viewLoad(_ input: Input) -> Output {
		return input.viewLoad
			.map { _ in
				let dummy = [
					"여행", "부동산", "가계", "기타등등", "5글자짜리", "여섯글자짜리"
				]
				return .load(dummy)
			}.eraseToAnyPublisher()
	}
	
	func nextButtonDidTap(_ input: Input) -> Output {
		return input.nextButtonDidTap
			.withUnretained(self)
			.map { (owner, _) in
				// useCase Login
				return .routeToNext(owner.categoryText)
			}.eraseToAnyPublisher()
	}
	
	func collectionViewCellDidSelect(_ input: Input) -> Output {
		input.collectionViewCellDidSelect
			.withUnretained(self)
			.map { (owner, text) in
				owner.categoryText = text
				return .none
			}.eraseToAnyPublisher()
	}
}
