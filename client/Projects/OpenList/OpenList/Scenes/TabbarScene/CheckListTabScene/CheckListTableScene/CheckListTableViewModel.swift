//
//  CheckListTableViewModel.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Combine

protocol CheckListTableViewModelable: ViewModelable 
where Input == CheckListTableInput,
      State == CheckListTableState,
      Output == AnyPublisher<State, Never> { }

final class CheckListTableViewModel {

}

extension CheckListTableViewModel: CheckListTableViewModelable {
  func transform(_ input: Input) -> Output {
		let viewLoad = viewLoad(input)
    return Publishers.MergeMany([
      viewLoad
		]).eraseToAnyPublisher()
  }
}

private extension CheckListTableViewModel {
	func viewLoad(_ input: Input) -> Output {
		return input.viewLoad
			.map { _ in
				let dummy = [
					CheckListTableItem(title: "hello"),
					CheckListTableItem(title: "hello2"),
					CheckListTableItem(title: "hello3")
				]
				return .reload(dummy)
			}
			.eraseToAnyPublisher()
	}
}
