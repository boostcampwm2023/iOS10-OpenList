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
}

extension SettingViewModel: SettingViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany([
			viewDidLoad(input)
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
}
