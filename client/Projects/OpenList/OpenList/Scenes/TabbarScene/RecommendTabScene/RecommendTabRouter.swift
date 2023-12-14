//
//  RecommendTabRouter.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import Foundation

final class RecommendTabRouter {
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

// MARK: - RecommendTabRoutingLogic
extension RecommendTabRouter: RecommendTabRoutingLogic {
	func showProfile() {
		let profileViewControllable = profileFactory.make()
		viewController?.pushViewController(profileViewControllable, animated: true)
	}
	
	func showSetting() {
		let settingViewControllable = settingFactory.make(with: appRouter)
		viewController?.pushViewController(settingViewControllable, animated: true)
	}
}
