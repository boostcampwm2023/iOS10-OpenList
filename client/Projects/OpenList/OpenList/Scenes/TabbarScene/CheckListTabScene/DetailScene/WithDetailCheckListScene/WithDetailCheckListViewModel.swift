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
	private var withCheckListUseCase: WithCheckListUseCase
	private var textChange: TextChange = .init()
	
	init(
		id: UUID,
		crdtUseCase: CRDTUseCase,
		withCheckListUseCase: WithCheckListUseCase
	) {
		self.id = id
		self.crdtUseCase = crdtUseCase
		self.withCheckListUseCase = withCheckListUseCase
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
			textShouldChange(input),
			textDidChange(input),
			appendDocument(input),
			removeDocument(input),
			receive(input),
			checklistToggle(input),
			deleteCheckList(input)
		).eraseToAnyPublisher()
	}
}
			
private extension WithDetailCheckListViewModel {
	func updateTitle(_ input: Input) -> Output {
		return input.viewLoad
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<CheckList, Never> in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.fetchCheckList(id: owner.id)
				})
				return future.eraseToAnyPublisher()
			}
			.map { checkList in
				return .viewLoad(checkList)
			}
			.eraseToAnyPublisher()
	}
	
	func textShouldChange(_ input: Input) -> Output {
		return input.textShouldChange
			.withUnretained(self)
			.map { owner, textChange in
				owner.textChange = textChange
				return .none
			}
			.eraseToAnyPublisher()
	}
	
	func textDidChange(_ input: Input) -> Output {
		return input.textDidChange
			.withUnretained(self)
			.flatMap { (owner, item) -> AnyPublisher<any ListItem, Never> in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.update(
						textChange: owner.textChange,
						currentText: item.text,
						isChecked: item.isChecked
					)
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
			.flatMap { (owner, editText) -> AnyPublisher<any ListItem, Never>  in
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
			.flatMap { (owner, editText) -> AnyPublisher<any ListItem, Never>  in
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
	
	func checklistToggle(_ input: Input) -> Output {
		return input.checklistDidTap
			.withUnretained(self)
			.flatMap { (owner, checkToggle) -> AnyPublisher<Void, Never> in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.updateCheckListState(to: checkToggle.id, isChecked: checkToggle.state)
				})
				return future.eraseToAnyPublisher()
			}
			.map { _ in return .checkToggle }
			.eraseToAnyPublisher()
	}
	
	func receive(_ input: Input) -> Output {
		return input.receive
			.withUnretained(self)
			.flatMap { (owner, jsonString) -> AnyPublisher<[any ListItem], Never>  in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.receive(jsonString)
				})
				return future.eraseToAnyPublisher()
			}
			.map { items in
				return .updateItems(items)
			}
			.eraseToAnyPublisher()
	}
	
	func deleteCheckList(_ input: Input) -> Output {
		return input.deleteCheckList
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<Void, Never>  in
				Future(asyncFunc: {
					try await owner.withCheckListUseCase.removeCheckList(id: owner.id)
				}).eraseToAnyPublisher()
			}
			.map { _ in
				return .dismiss
			}
			.eraseToAnyPublisher()
	}
}
