//
//  RecommendTabRouter.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import Foundation

final class RecommendTabRouter {
	weak var viewController: ViewControllable?
}

// MARK: - CheckListTabRoutingLogic
extension RecommendTabRouter: RecommendTabRoutingLogic {}
