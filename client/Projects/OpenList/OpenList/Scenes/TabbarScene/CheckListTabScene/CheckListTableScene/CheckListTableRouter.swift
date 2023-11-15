//
//  CheckListTableRouter.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Foundation

final class CheckListTableRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension CheckListTableRouter: CheckListTableRoutingLogic {}
