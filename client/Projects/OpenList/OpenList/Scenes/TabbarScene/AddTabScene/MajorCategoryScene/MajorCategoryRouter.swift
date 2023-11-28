//
//  MajorCategoryRouter.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Foundation

final class MajorCategoryRouter {
	weak var viewController: ViewControllable?
	weak var mediumCategoryViewControllable: ViewControllable?
	private var mediumCategoryFactory: MediumCategoryFactoryable
	
	init(
		viewController: ViewControllable? = nil,
		mediumCategoryViewControllable: ViewControllable? = nil,
		mediumCategoryFactory: MediumCategoryFactoryable
	) {
		self.viewController = viewController
		self.mediumCategoryViewControllable = mediumCategoryViewControllable
		self.mediumCategoryFactory = mediumCategoryFactory
	}
}

// MARK: - RoutingLogic
extension MajorCategoryRouter: MajorCategoryRoutingLogic {
	func routeToTitleView() {
		viewController?.popViewController(animated: true)
	}
	
	func routeToMediumCategoryView(with majorCategory: String) {
		let mediumCategoryViewControllable = mediumCategoryFactory.make(with: majorCategory)
		viewController?.pushViewController(mediumCategoryViewControllable, animated: true)
	}
	
	func routeToConfirmView() {
		dump("AI 추천 마지막 뷰로 이동")
	}
}
