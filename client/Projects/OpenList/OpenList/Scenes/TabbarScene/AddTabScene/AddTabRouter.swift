//
//  AddTabRouter.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

final class AddTabRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension AddTabRouter: AddTabRoutingLogic {}
