//
//  AddCheckListItemRouter.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import Foundation

final class AddCheckListItemRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension AddCheckListItemRouter: AddCheckListItemRoutingLogic {}
