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
extension SubCategoryRouter: SubCategoryRoutingLogic {
	func routeToMainCategoryView() {
		viewController?.popViewController(animated: true)
	}
	
	func routeToMinorCategoryView(with subCategory: String) {
		dump("다음 뷰로 이동")
	}
	
	func routeToConfirmView() {
		dump("AI 추천 마지막 뷰로 이동")
	}
}
