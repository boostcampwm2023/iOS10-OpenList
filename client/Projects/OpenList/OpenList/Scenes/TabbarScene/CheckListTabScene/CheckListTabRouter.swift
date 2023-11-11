//
//  CheckListTabRouter.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import Foundation

final class CheckListTabRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension CheckListTabRouter: CheckListTabRoutingLogic {}
