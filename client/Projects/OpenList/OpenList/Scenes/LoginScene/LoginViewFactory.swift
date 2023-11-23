//
//  LoginViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

protocol LoginDependency: Dependency { }

final class LoginComponent: Component<LoginDependency> { }

protocol LoginFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class LoginViewFactory: Factory<LoginDependency>, LoginFactoryable {
	override init(parent: LoginDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let router = LoginRouter()
		let viewModel = LoginViewModel()
		let viewController = LoginViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
