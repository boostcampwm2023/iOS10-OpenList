//
//  DetailCheckListViewModel.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Combine

protocol PrivateDetailCheckListViewModelable: ViewModelable
where Input == PrivateDetailCheckListInput,
  State == PrivateDetailCheckListState,
  Output == AnyPublisher<State, Never> { }

final class PrivateDetailCheckListViewModel {
	private var title: String
	
	init(title: String) {
		self.title = title
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
			.flatMap { [weak self] () -> AnyPublisher<String?, Never> in
				return Just(self?.title).eraseToAnyPublisher()
			}
			.map { title in
				return .title(title)
			}
			.eraseToAnyPublisher()
	}
}
