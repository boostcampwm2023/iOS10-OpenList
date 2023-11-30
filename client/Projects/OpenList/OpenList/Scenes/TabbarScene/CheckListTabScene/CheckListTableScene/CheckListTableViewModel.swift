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
	private let persistenceUseCase: PersistenceUseCase
	
	init(persistenceUseCase: PersistenceUseCase) {
		self.persistenceUseCase = persistenceUseCase
	}
}

extension CheckListTableViewModel: CheckListTableViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany(
			viewLoad(input),
			remove(input)
		).eraseToAnyPublisher()
  }
}

private extension CheckListTableViewModel {
	func viewLoad(_ input: Input) -> Output {
		return input.viewAppear
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<[CheckListTableItem], Never>  in
				let future = Future(asyncFunc: {
					await owner.persistenceUseCase.fetchAllCheckList()
				})
				return future.eraseToAnyPublisher()
			}
			.map { items in
				return .reload(items)
			}
			.eraseToAnyPublisher()
	}
	
	func remove(_ input: Input) -> Output {
		return input.removeCheckList
			.withUnretained(self)
			.flatMap { owner, uuid -> AnyPublisher<[CheckListTableItem], Never> in
				_ = owner.persistenceUseCase.removeCheckList(checklistId: uuid)
				let future = Future(asyncFunc: { await owner.persistenceUseCase.fetchAllCheckList() })
				return future.eraseToAnyPublisher()
			}
			.map { items in
				return .reload(items)
			}
			.eraseToAnyPublisher()
	}
}
	
