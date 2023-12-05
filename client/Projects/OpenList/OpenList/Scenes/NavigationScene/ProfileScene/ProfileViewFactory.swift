//
//  ProfileViewFactory.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import CustomNetwork
import Foundation

protocol ProfileDependency: Dependency {
	var session: CustomSession { get }
}

final class ProfileComponent: Component<ProfileDependency> {
	var session: CustomSession { parent.session }
	
	fileprivate var profileUsecase: ProfileUserCase {
		return DefaultProfileUserCase(profileRepository: profileRepository)
	}
	
	fileprivate var profileRepository: ProfileRepository {
		return DefaultProfileRepository(session: session)
	}
}

protocol ProfileFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class ProfileViewFactory: Factory<ProfileDependency>, ProfileFactoryable {
	override init(parent: ProfileDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let component = ProfileComponent(parent: parent)
		let router = ProfileRouter()
		let viewModel = ProfileViewModel(profileUseCase: component.profileUsecase)
		let viewController = ProfileViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
