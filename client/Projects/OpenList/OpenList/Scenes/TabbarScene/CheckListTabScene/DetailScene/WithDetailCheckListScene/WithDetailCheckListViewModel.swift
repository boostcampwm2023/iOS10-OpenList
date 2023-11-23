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
	private var webSocketUseCase: WebSocketUseCase
	
	init(
		title: String,
		crdtUseCase: CRDTUseCase,
		webSocketUseCase: WebSocketUseCase
	) {
		self.title = title
		self.crdtUseCase = crdtUseCase
		self.webSocketUseCase = webSocketUseCase
	}
}

extension WithDetailCheckListViewModel: WithDetailCheckListViewModelable {
	func transform(_ input: Input) -> Output {
		return Publishers.MergeMany<Output>(
			updateTitle(input),
			socketConnetion(input),
			receive(input),
			insert(input),
			delete(input)
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
	
	func socketConnetion(_ input: Input) -> Output {
		return input.socketConnet
			.withUnretained(self)
			.map { (owner, _) in
				let result = owner.webSocketUseCase.connect()
				return .socketConnet(result)
			}
			.eraseToAnyPublisher()
	}
	
	func insert(_ input: Input) -> Output {
		return input.insert
			.withUnretained(self)
			.flatMap { (owner, range) -> AnyPublisher<CRDTMessage, Never>  in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.insert(range: range)
				})
				return future.eraseToAnyPublisher()
			}
			.withUnretained(self)
			.map { (owner, message) in
				owner.webSocketUseCase.send(message: message)
				return .update("Insert")
			}
			.eraseToAnyPublisher()
	}
	
	func delete(_ input: Input) -> Output {
		return input.delete
			.withUnretained(self)
			.flatMap { (owner, range) -> AnyPublisher<CRDTMessage, Never>  in
				let future = Future(asyncFunc: {
					try await owner.crdtUseCase.delete(range: range)
				})
				return future.eraseToAnyPublisher()
			}
			.withUnretained(self)
			.map { (owner, message) in
				owner.webSocketUseCase.send(message: message)
				return .update("Delete")
			}
			.eraseToAnyPublisher()
	}
	
	func receive(_ input: Input) -> Output {
		return input.socketConnet
			.withUnretained(self)
			.flatMap { (owner, range) -> AnyPublisher<Node, Never>  in
				let future = Future(asyncFunc: {
					try await owner.webSocketUseCase.receive()
				})
				return future.eraseToAnyPublisher()
			}
			.map { text in
				print(text)
				return .update("Receive")
			}
			.eraseToAnyPublisher()
	}
}
