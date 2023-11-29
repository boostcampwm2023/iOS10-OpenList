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
	private var categoryInfo: Category
	private var subCategoryTitle: String = ""
	
	init(categoryInfo: Category) {
		self.categoryInfo = categoryInfo
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
				owner.categoryInfo.subCategory = owner.subCategoryTitle
				return .routeToNext(owner.categoryInfo)
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
