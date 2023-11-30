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

final class CheckListFolderViewModel {
	private let privateCheckListUseCase: PrivateCheckListUseCase
	
	init(privateCheckListUseCase: PrivateCheckListUseCase) {
		self.privateCheckListUseCase = privateCheckListUseCase
	}
}

extension CheckListFolderViewModel: CheckListFolderViewModelable {
	func transform(_ input: Input) -> Output {
		let viewWillAppear = viewWillAppear(input)
		return Publishers.MergeMany<Output>(viewWillAppear).eraseToAnyPublisher()
	}
}

private extension CheckListFolderViewModel {
	func viewWillAppear(_ input: Input) -> Output {
		return input.viewWillAppear
			.withUnretained(self)
			.flatMap { owner, _ -> AnyPublisher<Result<[CheckListFolderItem], Error>, Never> in
				return Future(asyncFunc: { await owner.privateCheckListUseCase.fetchAllFolders() })
					.eraseToAnyPublisher()
			}
			.map { result in
				switch result {
				case let .success(folders):
					return .folders(folders)
				case let .failure(error):
					return .error(error)
				}
			}
			.eraseToAnyPublisher()
	}
}
