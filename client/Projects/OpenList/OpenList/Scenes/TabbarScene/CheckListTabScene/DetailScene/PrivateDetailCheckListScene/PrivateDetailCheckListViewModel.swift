//
//  DetailCheckListViewModel.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Combine
import Foundation

enum DetailCheckListViewModelError: Error {
	case failedFetchData
	case failedSaveData
}

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
			viewWillAppear(input),
			append(input),
			update(input),
			remove(input),
			transformWith(input)
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
					return .error(DetailCheckListViewModelError.failedFetchData)
				}
				return .viewLoad(checkList)
			}
			.eraseToAnyPublisher()
	}
	
	func append(_ input: Input) -> Output {
		return input.append
			.withUnretained(self)
			.flatMap { (owner, item) -> AnyPublisher<CheckListItem?, Never>  in
				let future = Future(asyncFunc: {
					await owner.detailCheckListUseCase.appendItem(item)
				})
				return future.eraseToAnyPublisher()
			}
			.map { item in
				guard let item else {
					return .error(DetailCheckListViewModelError.failedSaveData)
				}
				return .updateItem(item)
			}
			.eraseToAnyPublisher()
	}
	
	func update(_ input: Input) -> Output {
		return input.update
			.withUnretained(self)
			.flatMap { (owner, item) -> AnyPublisher<CheckListItem?, Never>  in
				let future = Future(asyncFunc: {
					await owner.detailCheckListUseCase.updateItem(item)
				})
				return future.eraseToAnyPublisher()
			}
			.map { item in
				guard let item else {
					return .error(DetailCheckListViewModelError.failedSaveData)
				}
				return .updateItem(item)
			}
			.eraseToAnyPublisher()
	}
	
	func remove(_ input: Input) -> Output {
		return input.remove
			.withUnretained(self)
			.flatMap { (owner, item) -> AnyPublisher<CheckListItem?, Never>  in
				let future = Future(asyncFunc: {
					await owner.detailCheckListUseCase.removeItem(item)
				})
				return future.eraseToAnyPublisher()
			}
			.map { item in
				guard let item else {
					return .error(DetailCheckListViewModelError.failedSaveData)
				}
				return .updateItem(item)
			}
			.eraseToAnyPublisher()
	}
	
	func transformWith(_ input: Input) -> Output {
		return input.transformWith
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<Bool, Never>  in
				let future = Future(asyncFunc: {
					await owner.detailCheckListUseCase.transformWith()
				})
				return future.eraseToAnyPublisher()
			}
			.map { success in
				guard success else {
					return .error(DetailCheckListViewModelError.failedSaveData)
				}
				return .dismiss
			}
			.eraseToAnyPublisher()
	}
}
