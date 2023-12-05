//
//  ProfileViewModel.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import Combine

protocol ProfileViewModelable: ViewModelable
where Input == ProfileInput,
  State == ProfileState,
  Output == AnyPublisher<State, Never> { }

final class ProfileViewModel {

}

extension ProfileViewModel: ProfileViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany([
			viewDidLoad(input)
    ]).eraseToAnyPublisher()
  }
}

private extension ProfileViewModel {
	func viewDidLoad(_ input: Input) -> Output {
		return input.viewDidLoad
			.map {
				let user = User(userId: 1, email: "", fullName: "", nickname: "", profileImage: "")
				return .viewDidLoad(user)
			}
			.eraseToAnyPublisher()
	}
}
