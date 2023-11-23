//
//  WithDetailCheckListViewModel.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Combine

protocol WithDetailCheckListViewModelable: ViewModelable
where Input == WithDetailCheckListInput,
	State == WithDetailCheckListState,
	Output == AnyPublisher<State, Never> { }

final class WithDetailCheckListViewModel {
	private var title: String
	
	init(title: String) {
		self.title = title
	}
}

extension WithDetailCheckListViewModel: WithDetailCheckListViewModelable {
	func transform(_ input: Input) -> Output {
		return Publishers.MergeMany<Output>(
			viewWillAppear(input),
			insert(input),
			delete(input)
		).eraseToAnyPublisher()
	}
}
			
private extension WithDetailCheckListViewModel {
	func viewWillAppear(_ input: Input) -> Output {
		return input.viewWillAppear
			.flatMap { [weak self] () -> AnyPublisher<String?, Never> in
				return Just(self?.title).eraseToAnyPublisher()
			}
			.map { title in
				return .title(title)
			}
			.eraseToAnyPublisher()
	}
	
	func insert(_ input: Input) -> Output {
		return input.insert
			.map { _ in
				return .update("Insert")
			}
			.eraseToAnyPublisher()
	}
	
	func delete(_ input: Input) -> Output {
		return input.delete
			.map { _ in
				return .update("Delete")
			}
			.eraseToAnyPublisher()
	}
}
