//
//  ProfileViewFactory.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import Foundation

protocol ProfileDependency: Dependency { }

final class ProfileComponent: Component<ProfileDependency> { }

protocol ProfileFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class ProfileViewFactory: Factory<ProfileDependency>, ProfileFactoryable {
	override init(parent: ProfileDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let router = ProfileRouter()
		let viewModel = ProfileViewModel()
		let viewController = ProfileViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
