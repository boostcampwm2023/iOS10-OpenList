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
	private var profileFactory: ProfileFactoryable
	private var settingFactory: SettingFactoryable
	
	init(
		appRouter: AppRouterProtocol,
		profileFactory: ProfileFactoryable,
		settingFactory: SettingFactoryable
	) {
		self.appRouter = appRouter
		self.profileFactory = profileFactory
		self.settingFactory = settingFactory
	}
}

// MARK: - CheckListTabRoutingLogic
extension CheckListTabRouter: CheckListTabRoutingLogic {
	func showProfile() {
		let profileViewControllable = profileFactory.make()
		viewController?.pushViewController(profileViewControllable, animated: true)
	}
	
	func showSetting() {
		let settingViewControllable = settingFactory.make(with: appRouter)
		viewController?.pushViewController(settingViewControllable, animated: true)
	}
}
