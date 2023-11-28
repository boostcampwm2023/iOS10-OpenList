//
//  SharedCheckListViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import Foundation

protocol SharedCheckListDependency: Dependency {}

final class SharedCheckListComponent: Component<SharedCheckListDependency> {}

protocol SharedCheckListFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class SharedCheckListViewFactory: Factory<SharedCheckListDependency>, SharedCheckListFactoryable {
	override init(parent: SharedCheckListDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let router = SharedCheckListRouter()
		let viewModel = SharedCheckListViewModel()
		let viewController = SharedCheckListViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
