//
//  CheckListTabRouter.swift
//  OpenList
//
//  Created by wi_seong on 12/4/23.
//

import Foundation

final class CheckListTabRouter {
	weak var viewController: ViewControllable?
	private var appRouter: AppRouterProtocol
	private var settingFactory: SettingFactoryable
	weak var settingViewControllable: ViewControllable?
	
	init(appRouter: AppRouterProtocol, settingFactory: SettingFactoryable) {
		self.appRouter = appRouter
		self.settingFactory = settingFactory
	}
}

// MARK: - CheckListTabRoutingLogic
extension CheckListTabRouter: CheckListTabRoutingLogic {
	func showSetting() {
		let settingViewControllable = settingFactory.make(with: appRouter)
		self.settingViewControllable = settingViewControllable
		viewController?.pushViewController(settingViewControllable, animated: true)
	}
}
