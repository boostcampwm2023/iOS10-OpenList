//
//  CheckListFolderViewModel.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import Combine

protocol CheckListFolderViewModelable: ViewModelable
where Input == CheckListFolderInput,
	State == CheckListFolderState,
	Output == AnyPublisher<State, Never> { }

final class CheckListFolderViewModel { }

extension CheckListFolderViewModel: CheckListFolderViewModelable {
	func transform(_ input: Input) -> Output {
		return Publishers.MergeMany<Output>().eraseToAnyPublisher()
	}
}

private extension CheckListFolderViewModel { }
