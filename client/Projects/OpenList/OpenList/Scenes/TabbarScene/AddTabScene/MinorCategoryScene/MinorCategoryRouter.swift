//
//  MinorCategoryRouter.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

final class MinorCategoryRouter {
	weak var viewController: ViewControllable?
	private var addCheckListItemFactory: AddCheckListItemFactoryable
	
	init(
		viewController: ViewControllable? = nil,
		addCheckListItemFactory: AddCheckListItemFactoryable
	) {
		self.viewController = viewController
		self.addCheckListItemFactory = addCheckListItemFactory
	}
}

// MARK: - RoutingLogic
extension MinorCategoryRouter: MinorCategoryRoutingLogic {
	func routeToSubCategoryView() {
		viewController?.popViewController(animated: true)
	}
	
	func routeToConfirmView(categoryInfo: CategoryInfo) {
		let addCheckListItemViewControllable = addCheckListItemFactory.make()
		viewController?.pushViewController(addCheckListItemViewControllable, animated: true)
	}
}
