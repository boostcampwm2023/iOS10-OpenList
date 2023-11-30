//
//  WithDetailCheckListViewModel.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Combine
import CRDT

protocol WithDetailCheckListViewModelable: ViewModelable
where Input == WithDetailCheckListInput,
	State == WithDetailCheckListState,
	Output == AnyPublisher<State, Never> { }

protocol WithDetailCheckListDataSource {
	var inviteLinkUrlString: String { get }
	var webSocketUrl: URL? { get }
}

final class WithDetailCheckListViewModel {
	private var id: UUID
	private var crdtUseCase: CRDTUseCase
	
	init(
		id: UUID,
		crdtUseCase: CRDTUseCase
	) {
		self.id = id
		self.crdtUseCase = crdtUseCase
	}
}

extension WithDetailCheckListViewModel: WithDetailCheckListDataSource {
	var inviteLinkUrlString: String {
		"openlist://shared-checklists?shared-checklistId=\(id)"
	}
	
	var webSocketUrl: URL? {
		URL(string: "wss://openlist.kro.kr/share-checklist?cid=\(id)")
	}
}

extension WithDetailCheckListViewModel: WithDetailCheckListViewModelable {
	func transform(_ input: Input) -> Output {
		return Publishers.MergeMany<Output>(
			updateTitle(input),
			insert(input),
			delete(input),
			appendDocument(input),
			removeDocument(input),
			receive(input)
		).eraseToAnyPublisher()
	}
}
			
private extension WithDetailCheckListViewModel {
	func updateTitle(_ input: Input) -> Output {
		return input.viewWillAppear
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<CheckList, Never> in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.fetchCheckList(id: owner.id)
				})
				return future.eraseToAnyPublisher()
			}
			.map { checkList in
				return .viewWillAppear(checkList)
			}
			.eraseToAnyPublisher()
	}
	
	func insert(_ input: Input) -> Output {
		return input.insert
			.withUnretained(self)
			.flatMap { (owner, editText) -> AnyPublisher<CheckListItem, Never>  in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.insert(at: editText)
				})
				return future.eraseToAnyPublisher()
			}
			.map { _ in
				return .none
			}
			.eraseToAnyPublisher()
	}
	
	func delete(_ input: Input) -> Output {
		return input.delete
			.withUnretained(self)
			.flatMap { (owner, editText) -> AnyPublisher<CheckListItem, Never>  in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.delete(at: editText)
				})
				return future.eraseToAnyPublisher()
			}
			.map { _ in
				return .none
			}
			.eraseToAnyPublisher()
	}
	
	func appendDocument(_ input: Input) -> Output {
		return input.appendDocument
			.withUnretained(self)
			.flatMap { (owner, editText) -> AnyPublisher<CheckListItem, Never>  in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.appendDocument(at: editText)
				})
				return future.eraseToAnyPublisher()
			}
			.map { item in
				return .appendItem(item)
			}
			.eraseToAnyPublisher()
	}
	
	func removeDocument(_ input: Input) -> Output {
		return input.removeDocument
			.withUnretained(self)
			.flatMap { (owner, editText) -> AnyPublisher<CheckListItem, Never>  in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.removeDocument(at: editText)
				})
				return future.eraseToAnyPublisher()
			}
			.map { item in
				return .removeItem(item)
			}
			.eraseToAnyPublisher()
	}
	
	func receive(_ input: Input) -> Output {
		return input.receive
			.withUnretained(self)
			.flatMap { (owner, jsonString) -> AnyPublisher<[CheckListItem], Never>  in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.receive(jsonString)
				})
				return future.eraseToAnyPublisher()
			}
			.map { items in
				return .updateItem(items)
			}
			.eraseToAnyPublisher()
	}
}
