//
//  AddCheckListItemViewModel.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import Combine

protocol AddCheckListItemViewModelable: ViewModelable
where Input == AddCheckListItemInput,
  State == AddCheckListItemState,
  Output == AnyPublisher<State, Never> { }

final class AddCheckListItemViewModel { }

extension AddCheckListItemViewModel: AddCheckListItemViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany<Output>(
      viewDidLoad(input)
		).eraseToAnyPublisher()
  }
}

private extension AddCheckListItemViewModel {
	func viewDidLoad(_ input: Input) -> Output {
		return input.viewDidLoad
			.map { _ in
				return .viewDidLoad
			}
			.eraseToAnyPublisher()
	}
}
