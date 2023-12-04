//
//  CheckListTabRouter.swift
//  OpenList
//
//  Created by wi_seong on 12/4/23.
//

import Foundation

final class CheckListTabRouter {
	weak var viewController: ViewControllable?
	
	private var settingFactory: SettingFactoryable
	weak var settingViewControllable: ViewControllable?
	
	init(settingFactory: SettingFactoryable) {
		self.settingFactory = settingFactory
	}
}

// MARK: - CheckListTabRoutingLogic
extension CheckListTabRouter: CheckListTabRoutingLogic {
	func showSetting() {
		let settingViewControllable = settingFactory.make()
		self.settingViewControllable = settingViewControllable
		viewController?.pushViewController(settingViewControllable, animated: true)
	}
}
