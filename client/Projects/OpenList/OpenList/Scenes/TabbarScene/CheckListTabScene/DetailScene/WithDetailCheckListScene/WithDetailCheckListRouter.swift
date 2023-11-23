//
//  WithDetailCheckListRouter.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Foundation

final class WithDetailCheckListRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension WithDetailCheckListRouter: WithDetailCheckListRoutingLogic {}
