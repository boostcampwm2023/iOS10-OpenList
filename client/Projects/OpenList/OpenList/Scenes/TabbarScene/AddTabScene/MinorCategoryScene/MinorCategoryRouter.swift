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
extension MinorCategoryRouter: MinorCategoryRoutingLogic {
	func routeToSubCategoryView() {
		viewController?.popViewController(animated: true)
	}
	
	func routeToConfirmView(category: Category? = nil) {
		dump(category)
		dump("AI 추천 마지막 뷰로 이동")
	}
}
