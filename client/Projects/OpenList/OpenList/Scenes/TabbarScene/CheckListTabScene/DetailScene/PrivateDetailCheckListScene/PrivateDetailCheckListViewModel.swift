//
//  DetailCheckListViewModel.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Combine
import Foundation

protocol PrivateDetailCheckListViewModelable: ViewModelable
where Input == PrivateDetailCheckListInput,
  State == PrivateDetailCheckListState,
  Output == AnyPublisher<State, Never> { }

protocol PrivateDetailCheckListDataSource {
	var checkListId: String { get }
}

final class PrivateDetailCheckListViewModel {
	private var id: UUID
	private var detailCheckListUseCase: DetailCheckListUseCase
	
	init(
		id: UUID,
		detailCheckListUseCase: DetailCheckListUseCase
	) {
		self.id = id
		self.detailCheckListUseCase = detailCheckListUseCase
	}
}

extension PrivateDetailCheckListViewModel: PrivateDetailCheckListDataSource {
	var checkListId: String {
		id.uuidString
	}
}

extension PrivateDetailCheckListViewModel: PrivateDetailCheckListViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany<Output>(
			viewWillAppear(input)
		).eraseToAnyPublisher()
  }
}
			
private extension PrivateDetailCheckListViewModel {
	func viewWillAppear(_ input: Input) -> Output {
		return input.viewWillAppear
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<CheckList?, Never>  in
				let future = Future(asyncFunc: {
					await owner.detailCheckListUseCase.fetchCheckList(id: owner.id)
				})
				return future.eraseToAnyPublisher()
			}
			.map { checkList in
				guard let checkList = checkList else {
					return .title("fail")
				}
				return .title(checkList.title)
			}
			.eraseToAnyPublisher()
	}
}