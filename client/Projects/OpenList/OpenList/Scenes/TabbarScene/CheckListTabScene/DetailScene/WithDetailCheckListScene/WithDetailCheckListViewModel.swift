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

final class WithDetailCheckListViewModel {
	private var title: String
	private var crdtUseCase: CRDTUseCase
	
	init(
		title: String,
		crdtUseCase: CRDTUseCase
	) {
		self.title = title
		self.crdtUseCase = crdtUseCase
	}
}

extension WithDetailCheckListViewModel: WithDetailCheckListViewModelable {
	func transform(_ input: Input) -> Output {
		return Publishers.MergeMany<Output>(
			updateTitle(input),
			insert(input),
			delete(input),
			receive(input)
		).eraseToAnyPublisher()
	}
}
			
private extension WithDetailCheckListViewModel {
	func updateTitle(_ input: Input) -> Output {
		return input.viewWillAppear
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<String?, Never> in
				return Just(owner.title).eraseToAnyPublisher()
			}
			.map { title in
				return .title(title)
			}
			.eraseToAnyPublisher()
	}
	
	func insert(_ input: Input) -> Output {
		return input.insert
			.withUnretained(self)
			.flatMap { (owner, editText) -> AnyPublisher<CRDTMessage, Never>  in
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
			.flatMap { (owner, editText) -> AnyPublisher<CRDTMessage, Never>  in
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
	
	func receive(_ input: Input) -> Output {
		return input.receive
			.withUnretained(self)
			.flatMap { (owner, data) -> AnyPublisher<String, Never>  in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.receive(data: data)
				})
				return future.eraseToAnyPublisher()
			}
			.map { text in
				return .update(text)
			}
			.eraseToAnyPublisher()
	}
}
