//
//  LoginViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import CustomNetwork
import Foundation

protocol LoginDependency: Dependency {}

final class LoginComponent:
	Component<LoginDependency>, TabBarDependency {
	fileprivate var authRepository: AuthRepository {
		return DefaultAuthRepository()
	}
	
	fileprivate var loginUseCase: AuthUseCase {
		return DefaultAuthUseCase(defaultAuthRepository: authRepository)
	}
	
	fileprivate var tabBarFactoryable: TabBarFactoryable {
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
		let component = LoginComponent(parent: parent)
		let router = LoginRouter(parentRouter: parentRouter)
		let viewModel = LoginViewModel(loginUseCase: component.loginUseCase)
		let viewController = LoginViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
