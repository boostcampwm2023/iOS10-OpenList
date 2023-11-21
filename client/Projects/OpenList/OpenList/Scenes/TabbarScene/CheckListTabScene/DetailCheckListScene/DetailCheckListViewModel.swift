//
//  DetailCheckListViewModel.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Combine

protocol DetailCheckListViewModelable: ViewModelable
where Input == DetailCheckListInput,
  State == DetailCheckListState,
  Output == AnyPublisher<State, Never> { }

final class DetailCheckListViewModel {
	private var title: String
	
	init(title: String) {
		self.title = title
	}
}

extension DetailCheckListViewModel: DetailCheckListViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany<Output>(
			viewWillAppear(input)
		).eraseToAnyPublisher()
  }
}
			
private extension DetailCheckListViewModel {
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
