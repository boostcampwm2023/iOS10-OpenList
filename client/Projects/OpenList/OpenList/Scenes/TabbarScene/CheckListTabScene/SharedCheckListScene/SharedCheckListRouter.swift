//
//  SharedCheckListRouter.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import Foundation

final class SharedCheckListRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension SharedCheckListRouter: SharedCheckListRoutingLogic {}
