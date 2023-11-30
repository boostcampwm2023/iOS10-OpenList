//
//  CheckListTableViewModel.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Combine

protocol CheckListTableViewModelable: ViewModelable
where Input == CheckListTableInput,
	State == CheckListTableState,
  Output == AnyPublisher<State, Never> { }

final class CheckListTableViewModel {
	private let withCheckListUseCase: WithCheckListUseCase
	
	init(withCheckListUseCase: WithCheckListUseCase) {
		self.withCheckListUseCase = withCheckListUseCase
	}
}

extension CheckListTableViewModel: CheckListTableViewModelable {
  func transform(_ input: Input) -> Output {
		let viewLoad = viewLoad(input)
    return Publishers.MergeMany(
			[
				viewLoad
			]
		).eraseToAnyPublisher()
  }
}

private extension CheckListTableViewModel {
	func viewLoad(_ input: Input) -> Output {
		return input.viewAppear
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<[CheckListTableItem], Never>  in
				let future = Future(asyncFunc: {
					await owner.withCheckListUseCase.fetchAllCheckList()
				})
				return future.eraseToAnyPublisher()
			}
			.map { items in
				return .reload(items)
			}
			.eraseToAnyPublisher()
	}
}
