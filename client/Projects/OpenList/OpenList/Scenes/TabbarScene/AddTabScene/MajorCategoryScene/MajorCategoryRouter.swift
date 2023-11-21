//
//  MajorCategoryRouter.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Foundation

final class MajorCategoryRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension MajorCategoryRouter: MajorCategoryRoutingLogic {}
