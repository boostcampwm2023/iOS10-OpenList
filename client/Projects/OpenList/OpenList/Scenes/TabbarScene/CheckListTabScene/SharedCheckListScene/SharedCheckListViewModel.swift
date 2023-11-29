//
//  SharedCheckListViewModel.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import Combine

protocol SharedCheckListViewModelable: ViewModelable
where Input == SharedCheckListInput,
	State == SharedCheckListState,
	Output == AnyPublisher<State, Never> { }

final class SharedCheckListViewModel {}

extension SharedCheckListViewModel: SharedCheckListViewModelable {
	func transform(_ input: Input) -> Output {
		return Publishers.MergeMany<Output>().eraseToAnyPublisher()
	}
}

private extension SharedCheckListViewModel {}
