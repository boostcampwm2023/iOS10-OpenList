//
//  MediumCategoryRouter.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

final class MediumCategoryRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension MediumCategoryRouter: MediumCategoryRoutingLogic {}
