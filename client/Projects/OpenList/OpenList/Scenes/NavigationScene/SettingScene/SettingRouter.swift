//
//  SettingRouter.swift
//  OpenList
//
//  Created by wi_seong on 12/4/23.
//

import Foundation

final class SettingRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension SettingRouter: SettingRoutingLogic {
	func dismissSettingScene() {
		viewController?.popViewController(animated: true)
	}
}
