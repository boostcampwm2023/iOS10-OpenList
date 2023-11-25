//
//  LoginViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

protocol LoginDependency: Dependency {
	var loginUseCase: LoginUseCase { get }
}

final class LoginComponent:
	Component<LoginDependency>, TabBarDependency {
	var tabBarFactoryable: TabBarFactoryable {
		return TabBarViewFactory(parent: self)
	}
}

protocol LoginFactoryable: Factoryable {
	func make(with parentRouter: AppRouterProtocol) -> ViewControllable
}

final class LoginViewFactory: Factory<LoginDependency>, LoginFactoryable {
	override init(parent: LoginDependency) {
		super.init(parent: parent)
	}
	
	func make(with parentRouter: AppRouterProtocol) -> ViewControllable {
		let router = LoginRouter(parentRouter: parentRouter)
		let viewModel = LoginViewModel(loginUseCase: parent.loginUseCase)
		let viewController = LoginViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
