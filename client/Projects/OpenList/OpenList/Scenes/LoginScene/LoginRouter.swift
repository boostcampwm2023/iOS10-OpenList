//
//  LoginRouter.swift
//  OpenList
//
//  Created by Hoon on 11/23/23.
//

import Foundation

final class LoginRouter {
	weak var viewController: ViewControllable?
	var parentRouter: AppRouterProtocol?
	
	init(parentRouter: AppRouterProtocol?) {
		self.parentRouter = parentRouter
	}
}

// MARK: - RoutingLogic
extension LoginRouter: LoginRoutingLogic {
	func routeToTabBarScene() {
		parentRouter?.showTapFlow()
	}
}
