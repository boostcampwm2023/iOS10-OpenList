//
//  DetailCheckListViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Foundation

protocol PrivateDetailCheckListDependency: Dependency {}

final class PrivateDetailCheckListComponent: Component<PrivateDetailCheckListDependency> {}

protocol PrivateDetailCheckListFactoryable: Factoryable {
	func make(with title: String) -> ViewControllable
}

final class PrivateDetailCheckListViewFactory:
	Factory<PrivateDetailCheckListDependency>,
	PrivateDetailCheckListFactoryable {
	override init(parent: PrivateDetailCheckListDependency) {
		super.init(parent: parent)
	}
	
	func make(with title: String) -> ViewControllable {
		let router = PrivateDetailCheckListRouter()
		let viewModel = PrivateDetailCheckListViewModel(title: title)
		let viewController = PrivateDetailCheckListViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
