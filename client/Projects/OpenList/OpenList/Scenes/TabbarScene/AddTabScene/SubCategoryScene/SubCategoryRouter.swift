//
//  SubCategoryRouter.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

final class SubCategoryRouter {
	weak var viewController: ViewControllable?
	weak var minorCategoryViewControllable: ViewControllable?
	private var minorCategoryFactory: MinorCategoryFactoryable
	
	init(
		viewController: ViewControllable? = nil,
		minorCategoryViewControllable: ViewControllable? = nil,
		minorCategoryFactory: MinorCategoryFactoryable
	) {
		self.viewController = viewController
		self.minorCategoryViewControllable = minorCategoryViewControllable
		self.minorCategoryFactory = minorCategoryFactory
	}
}

// MARK: - RoutingLogic
extension SubCategoryRouter: SubCategoryRoutingLogic {
	func routeToMainCategoryView() {
		viewController?.popViewController(animated: true)
	}
	
	func routeToMinorCategoryView(_ title: String, _ mainCategory: CategoryItem, _ subCategory: CategoryItem) {
		let minorCategoryViewControllable = minorCategoryFactory.make(title, mainCategory, subCategory)
		viewController?.pushViewController(minorCategoryViewControllable, animated: true)
	}
	
	func routeToConfirmView(_ categoryInfo: CategoryInfo) {
		dump(categoryInfo.title!)
		dump("AI 추천 마지막 뷰로 이동")
	}}
