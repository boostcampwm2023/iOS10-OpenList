//
//  SubCategoryRouter.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

final class SubCategoryRouter {
	weak var viewController: ViewControllable?
	private var minorCategoryFactory: MinorCategoryFactoryable
	private var addCheckListItemFactory: AddCheckListItemFactoryable
	
	init(
		viewController: ViewControllable? = nil,
		minorCategoryFactory: MinorCategoryFactoryable,
		addCheckListItemFactory: AddCheckListItemFactoryable
	) {
		self.viewController = viewController
		self.minorCategoryFactory = minorCategoryFactory
		self.addCheckListItemFactory = addCheckListItemFactory
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
		let addCheckListItemViewControllable = addCheckListItemFactory.make()
		viewController?.pushViewController(addCheckListItemViewControllable, animated: true)
	}}
