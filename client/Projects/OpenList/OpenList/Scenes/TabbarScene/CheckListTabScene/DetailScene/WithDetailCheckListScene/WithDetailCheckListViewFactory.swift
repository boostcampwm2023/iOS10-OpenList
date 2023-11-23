//
//  WithDetailCheckListViewFactory.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Foundation

protocol WithDetailCheckListDependency: Dependency {}

final class WithDetailCheckListComponent: Component<WithDetailCheckListDependency> {}

protocol WithDetailCheckListFactoryable: Factoryable {
	func make(with title: String) -> ViewControllable
}

final class WithDetailCheckListViewFactory: Factory<WithDetailCheckListDependency>, WithDetailCheckListFactoryable {
	override init(parent: WithDetailCheckListDependency) {
		super.init(parent: parent)
	}
	
	func make(with title: String) -> ViewControllable {
		let router = WithDetailCheckListRouter()
		let viewModel = WithDetailCheckListViewModel(title: title)
		let viewController = WithDetailCheckListViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
