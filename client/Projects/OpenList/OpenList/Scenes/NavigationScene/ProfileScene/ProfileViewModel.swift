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

protocol ProfileViewModelDataSource {
	var nickname: String { get }
}

final class ProfileViewModel {
	private let profileUseCase: ProfileUserCase
	private var user: User?
	
	init(profileUseCase: ProfileUserCase) {
		self.profileUseCase = profileUseCase
	}
}

extension ProfileViewModel: ProfileViewModelDataSource {
	var nickname: String {
		user?.nickname ?? ""
	}
}

extension ProfileViewModel: ProfileViewModelable {
  func transform(_ input: Input) -> Output {
    return Publishers.MergeMany([
			viewDidLoad(input),
			updateNickname(input)
    ]).eraseToAnyPublisher()
  }
}

private extension ProfileViewModel {
	func viewDidLoad(_ input: Input) -> Output {
		return input.viewDidLoad
			.withUnretained(self)
			.map { owner, _ in
				let nickname = Storage.shared.fetch(key: .nickname) as? String
				let user = User(userId: 1, email: "", fullName: "", nickname: nickname ?? "", profileImage: "")
				owner.user = user
				return .viewDidLoad(user)
			}
			.eraseToAnyPublisher()
	}
	
	func updateNickname(_ input: Input) -> Output {
		return input.updateNickname
			.withUnretained(self)
			.map { owner, nickname in
				owner.profileUseCase.updateNickname(to: nickname)
				owner.user?.nickname = nickname
				return .updateNickname(nickname)
			}
			.eraseToAnyPublisher()
	}
}
