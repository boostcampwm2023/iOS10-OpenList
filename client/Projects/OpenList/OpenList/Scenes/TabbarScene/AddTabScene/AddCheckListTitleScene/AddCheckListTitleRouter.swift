//
//  AddCheckListTitleRouter.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import Foundation

final class AddCheckListTitleRouter {
	weak var viewController: ViewControllable?
	weak var majorCategoryViewControllable: ViewControllable?
	private var majorCategoryViewFactory: MajorCategoryFactoryable
	
	init(
		viewController: ViewControllable? = nil,
		majorCategoryViewFactory: MajorCategoryFactoryable,
		majorCategoryViewControllable: ViewControllable? = nil
	) {
		self.viewController = viewController
		self.majorCategoryViewFactory = majorCategoryViewFactory
		self.majorCategoryViewControllable = majorCategoryViewControllable
	}
}

// MARK: - RoutingLogic
extension AddCheckListTitleRouter: AddCheckListTitleRoutingLogic {
	func routeToMajorCategoryScene(with title: String) {
		let majorCategoryViewControllable = majorCategoryViewFactory.make(with: title)
		viewController?.pushViewController(majorCategoryViewControllable, animated: true)
	}
}
