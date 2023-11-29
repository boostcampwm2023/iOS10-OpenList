//
//  SubCategoryRouter.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

final class SubCategoryRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension SubCategoryRouter: SubCategoryRoutingLogic {}
