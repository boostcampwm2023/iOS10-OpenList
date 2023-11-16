//
//  DetailCheckListViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Foundation

protocol DetailCheckListDependency: Dependency {}

final class DetailCheckListComponent: Component<DetailCheckListDependency> {}

protocol DetailCheckListFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class DetailCheckListViewFactory: Factory<DetailCheckListDependency>, DetailCheckListFactoryable {
	override init(parent: DetailCheckListDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let router = DetailCheckListRouter()
		let viewModel = DetailCheckListViewModel()
		let viewController = DetailCheckListViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
