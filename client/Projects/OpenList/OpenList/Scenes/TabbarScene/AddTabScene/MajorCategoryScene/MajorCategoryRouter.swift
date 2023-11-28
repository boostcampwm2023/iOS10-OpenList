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
extension MajorCategoryRouter: MajorCategoryRoutingLogic {
	func routeToMediumCategoryView(with majorCategory: String) {
		dump("\(majorCategory)를 가지고 다음 뷰로 이동")
	}
	
	func routeToConfirmView() {
		dump("AI 추천 마지막 뷰로 이동")
	}
}
