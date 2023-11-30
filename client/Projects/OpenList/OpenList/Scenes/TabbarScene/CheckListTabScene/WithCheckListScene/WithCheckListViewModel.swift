//
//  WithCheckListViewModel.swift
//  OpenList
//
//  Created by 김영균 on 11/30/23.
//

import Combine

protocol WithCheckListViewModelable: ViewModelable
where Input == WithCheckListInput,
  State == WithCheckListState,
  Output == AnyPublisher<State, Never> { }

final class WithCheckListViewModel {}

extension WithCheckListViewModel: WithCheckListViewModelable {
  func transform(_ input: Input) -> Output {
		let viewWillAppear = viewLoad(input)
    return Publishers.MergeMany<Output>(viewWillAppear).eraseToAnyPublisher()
  }
}

private extension WithCheckListViewModel {
	func viewLoad(_ input: Input) -> Output {
		return input.viewWillAppear
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<[CheckListTableItem], Never> in
				let future = Future(asyncFunc: {
					let item: [CheckListTableItem] = []
					return item
				})
				return future.eraseToAnyPublisher()
			}
			.map { items in
				return .reload(items)
			}
			.eraseToAnyPublisher()
	}
}
