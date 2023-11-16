//
//  DetailCheckListRouter.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Foundation

final class DetailCheckListRouter {
	weak var viewController: ViewControllable?
}

// MARK: - RoutingLogic
extension DetailCheckListRouter: DetailCheckListRoutingLogic {}
