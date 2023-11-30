//
//  AddCheckListTitleRouter.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

final class AddCheckListTitleRouter {
	weak var viewController: ViewControllable?
	private var mainCategoryViewFactory: MainCategoryFactoryable
	
	init(
		viewController: ViewControllable? = nil,
		mainCategoryViewFactory: MainCategoryFactoryable
	) {
		self.viewController = viewController
		self.mainCategoryViewFactory = mainCategoryViewFactory
	}
}

// MARK: - RoutingLogic
extension AddCheckListTitleRouter: AddCheckListTitleRoutingLogic {
	func routeToMainCategoryScene(with title: String) {
		let mainCategoryViewControllable = mainCategoryViewFactory.make(with: title)
		viewController?.pushViewController(mainCategoryViewControllable, animated: true)
	}
}
