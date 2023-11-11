//
//  AddTabRouter.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import Foundation

final class AddTabRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension AddTabRouter: AddTabRoutingLogic {}
