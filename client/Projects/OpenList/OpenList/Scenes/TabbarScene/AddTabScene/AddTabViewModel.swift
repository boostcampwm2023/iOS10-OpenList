//
//  AddTabViewModel.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Combine

protocol AddTabViewModelable: ViewModelable
where Input == AddTabInput,
  State == AddTabState,
  Output == AnyPublisher<State, Never> { }

final class AddTabViewModel {
	private let validCheckUseCase: ValidCheckUseCase
	private let persistenceUseCase: PersistenceUseCase
	private var title: String = ""
	
	enum Constant {
		static let titleMaxLength = 30
	}
	
	init(
		validCheckUseCase: ValidCheckUseCase,
		persistenceUseCase: PersistenceUseCase
	) {
		self.validCheckUseCase = validCheckUseCase
		self.persistenceUseCase = persistenceUseCase
	}
}

extension AddTabViewModel: AddTabViewModelable {
  func transform(_ input: Input) -> Output {
		let textFieldDidChange = textFieldDidChange(input)
		let nextButtonDidTap = nextButtonDidTap(input)
    return Publishers.MergeMany([
			textFieldDidChange,
			nextButtonDidTap
    ]).eraseToAnyPublisher()
  }
}

private extension AddTabViewModel {
	func textFieldDidChange(_ input: Input) -> Output {
		return input.textFieldDidChange
			.withUnretained(self)
			.map { (owner, text) in
				let state = owner.validCheckUseCase.validateTextLength(text, in: Constant.titleMaxLength)
				owner.title = text
				return .valid(state)
			}
			.eraseToAnyPublisher()
	}
	
	func nextButtonDidTap(_ input: Input) -> Output {
		return input.nextButtonDidTap
			.withUnretained(self)
			.map { (owner, _) in
				Task {
					let result = await owner.persistenceUseCase.saveCheckList(title: owner.title)
					print(result)
				}
				return .dismiss
			}
			.eraseToAnyPublisher()
	}
}
