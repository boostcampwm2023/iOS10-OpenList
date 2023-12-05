//
//  SettingViewModel.swift
//  OpenList
//
//  Created by wi_seong on 12/4/23.
//

import Combine

protocol SettingViewModelable: ViewModelable
where Input == SettingInput,
  State == SettingState,
  Output == AnyPublisher<State, Never> { }

final class SettingViewModel {
	enum Constant {
		static let titles = ["로그아웃", "회원탈퇴"]
	}
	
	private let settingUseCase: SettingUseCase
	
	init(settingUseCase: SettingUseCase) {
		self.settingUseCase = settingUseCase
	}
}

extension SettingViewModel: SettingViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany([
			viewDidLoad(input),
			logOut(input),
			deleteAccount(input)
    ]).eraseToAnyPublisher()
  }
}

private extension SettingViewModel {
	func viewDidLoad(_ input: Input) -> Output {
		return input.viewDidLoad
			.map {
				let items = Constant.titles.map {
					SettingItem(title: $0)
				}
				return .reload(items)
			}
			.eraseToAnyPublisher()
	}
	
	func logOut(_ input: Input) -> Output {
		return input.logOut
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<Void, Never>  in
				let future = Future(asyncFunc: {
					try await owner.settingUseCase.logOut()
				})
				return future.eraseToAnyPublisher()
			}
			.map {
				return .showLogin
			}
			.eraseToAnyPublisher()
	}
	
	func deleteAccount(_ input: Input) -> Output {
		return input.deleteAccount
			.withUnretained(self)
			.flatMap { (owner, _) -> AnyPublisher<Void, Never>  in
				let future = Future(asyncFunc: {
					try await owner.settingUseCase.deleteAccount()
				})
				return future.eraseToAnyPublisher()
			}
			.map {
				return .showLogin
			}
			.eraseToAnyPublisher()
	}
}
