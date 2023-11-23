//
//  LoginViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

protocol LoginDependency: Dependency { }

final class LoginComponent: Component<LoginDependency> {
	// TODO: 부모에게 넘겨받은 의존성을 가지고  Login 뷰를 만드는데 필요한 의존성을 만듭니다.
	// 또한 자식 뷰에게 넘겨줄 의존성도 정의할 수 있습니다.
}

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
