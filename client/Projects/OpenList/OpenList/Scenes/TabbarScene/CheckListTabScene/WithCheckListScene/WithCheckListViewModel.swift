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

final class WithCheckListViewModel {
	private let withCheckListUseCase: WithCheckListUseCase
	
	init(withCheckListUseCase: WithCheckListUseCase) {
		self.withCheckListUseCase = withCheckListUseCase
	}
}

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
			.flatMap { (owner, _) -> AnyPublisher<[WithCheckList], Never> in
				return Future(asyncFunc: {
					return await owner.withCheckListUseCase.fetchAllCheckList()
				}).eraseToAnyPublisher()
			}
			.map { items in
				return .reload(items)
			}
			.eraseToAnyPublisher()
	}
}
