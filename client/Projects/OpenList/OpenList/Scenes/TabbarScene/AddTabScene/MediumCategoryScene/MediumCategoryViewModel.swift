//
//  MediumCategoryViewModel.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Combine

protocol MediumCategoryViewModelable: ViewModelable
where Input == MediumCategoryInput,
State == MediumCategoryState,
Output == AnyPublisher<State, Never> { }

final class MediumCategoryViewModel {
	private let majorCategoryTitle: String
	private var mediumCategoryTitle: String = ""
	private var cancellables: Set<AnyCancellable> = []
	
	init(majorCategoryTitle: String) {
		self.majorCategoryTitle = majorCategoryTitle
	}
}

extension MediumCategoryViewModel: MediumCategoryViewModelable {
  func transform(_ input: Input) -> Output {
		let viewLoad = viewLoad(input)
		let nextButtonDidTap = nextButtonDidTap(input)
		collectionViewCellDidSelect(input)
    return Publishers.MergeMany([
			viewLoad,
			nextButtonDidTap
    ]).eraseToAnyPublisher()
  }
}

private extension MediumCategoryViewModel {
	func viewLoad(_ input: Input) -> Output {
		return input.viewLoad
			.map { _ in
				let dummy = [
					"부산여행", "마산여행", "제주여행", "일산여행", "무안여행", "성훈이집여행",
					"댄싱빈스여행", "애플코리아여행", "캘리포니아여행", "서울구경", "경복궁여행"
				]
				return .load(dummy)
			}.eraseToAnyPublisher()
	}
	
	func nextButtonDidTap(_ input: Input) -> Output {
		return input.nextButtonDidTap
			.withUnretained(self)
			.map { (owner, _) in
				// useCase Login
				return .routeToNext(owner.mediumCategoryTitle)
			}.eraseToAnyPublisher()
	}
	
	func collectionViewCellDidSelect(_ input: Input) {
		input.collectionViewCellDidSelect
			.withUnretained(self)
			.sink { (owner, text) in
				owner.mediumCategoryTitle = text
			}
			.store(in: &cancellables)
	}
}
