//
//  SettingRouter.swift
//  OpenList
//
//  Created by wi_seong on 12/4/23.
//

import Foundation

final class SettingRouter {
	weak var viewController: ViewControllable?
	private var appRouter: AppRouterProtocol
	
	init(appRouter: AppRouterProtocol) {
		self.appRouter = appRouter
	}
}

// MARK: - RoutingLogic
extension SettingRouter: SettingRoutingLogic {
	func routeToLoginScene() {
		appRouter.showLoginFlow()
	}
	
	func dismissSettingScene() {
		viewController?.popViewController(animated: true)
	}
}
