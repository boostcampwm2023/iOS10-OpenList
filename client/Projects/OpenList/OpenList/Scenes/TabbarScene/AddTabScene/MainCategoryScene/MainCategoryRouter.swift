//
//  MainCategoryRouter.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Foundation

final class MainCategoryRouter {
	weak var viewController: ViewControllable?
	weak var subCategoryViewControllable: ViewControllable?
	private var subCategoryFactory: SubCategoryFactoryable
	
	init(
		viewController: ViewControllable? = nil,
		subCategoryViewControllable: ViewControllable? = nil,
		subCategoryFactory: SubCategoryFactoryable
	) {
		self.viewController = viewController
		self.subCategoryViewControllable = subCategoryViewControllable
		self.subCategoryFactory = subCategoryFactory
	}
}

// MARK: - RoutingLogic
extension MainCategoryRouter: MainCategoryRoutingLogic {
	func routeToTitleView() {
		viewController?.popViewController(animated: true)
	}
	
	func routeToSubCategoryView(with mainCategory: CategoryItem) {
		let subCategoryViewControllable = subCategoryFactory.make(with: mainCategory)
		viewController?.pushViewController(subCategoryViewControllable, animated: true)
	}
	
	func routeToConfirmView() {
		dump("AI 추천 마지막 뷰로 이동")
	}
}
