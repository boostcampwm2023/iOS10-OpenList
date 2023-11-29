//
//  MinorCategoryRouter.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

final class MinorCategoryRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension MinorCategoryRouter: MinorCategoryRoutingLogic {}
