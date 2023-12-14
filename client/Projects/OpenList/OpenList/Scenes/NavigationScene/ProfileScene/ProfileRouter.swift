//
//  ProfileRouter.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import Foundation

final class ProfileRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension ProfileRouter: ProfileRoutingLogic {
	func dismissProfileScene() {
		viewController?.popViewController(animated: true)
	}
}
