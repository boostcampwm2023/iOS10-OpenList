//
//  CheckListTableRouter.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Foundation

final class CheckListTableRouter {
	weak var viewController: ViewControllable?
	
	private var detailCheckListViewFactory: WithDetailCheckListFactoryable
	weak var detailCheckListViewControllable: ViewControllable?
	
	init(detailCheckListViewFactory: WithDetailCheckListFactoryable) {
		self.detailCheckListViewFactory = detailCheckListViewFactory
	}
}

// MARK: - RoutingLogic
extension CheckListTableRouter: CheckListTableRoutingLogic {
	func routeToDetailScene(with title: String) {
		let detailCheckListViewControllable = detailCheckListViewFactory.make(with: title)
		self.detailCheckListViewControllable = detailCheckListViewControllable
		viewController?.pushViewController(detailCheckListViewControllable, animated: true)
	}
}
