//
//  CheckListTableViewFactory.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Foundation

protocol CheckListTableDependency: Dependency { }

final class CheckListTableComponent: Component<CheckListTableDependency> { }

protocol CheckListTableFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class CheckListTableViewFactory: Factory<CheckListTableDependency>, CheckListTableFactoryable {
	override init(parent: CheckListTableDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let router = CheckListTableRouter()
		let viewModel = CheckListTableViewModel()
		let viewController = CheckListTableViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
