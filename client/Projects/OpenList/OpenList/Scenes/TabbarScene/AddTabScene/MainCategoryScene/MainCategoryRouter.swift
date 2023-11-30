//
//  MainCategoryRouter.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Foundation

final class MainCategoryRouter {
	weak var viewController: ViewControllable?
	private var subCategoryFactory: SubCategoryFactoryable
	private var addCheckListItemFactory: AddCheckListItemFactoryable
	
	init(
		viewController: ViewControllable? = nil,
		subCategoryFactory: SubCategoryFactoryable,
		addCheckListItemFactory: AddCheckListItemFactoryable
	) {
		self.viewController = viewController
		self.subCategoryFactory = subCategoryFactory
		self.addCheckListItemFactory = addCheckListItemFactory
	}
}

// MARK: - RoutingLogic
extension MainCategoryRouter: MainCategoryRoutingLogic {
	func routeToTitleView() {
		viewController?.popViewController(animated: true)
	}
	
	func routeToSubCategoryView(_ title: String, _ mainCategory: CategoryItem) {
		let subCategoryViewControllable = subCategoryFactory.make(title, mainCategory)
		viewController?.pushViewController(subCategoryViewControllable, animated: true)
	}
	
	func routeToConfirmView(_ categoryInfo: CategoryInfo) {
		let addCheckListItemViewControllable = addCheckListItemFactory.make(with: categoryInfo)
		viewController?.pushViewController(addCheckListItemViewControllable, animated: true)
	}
}
