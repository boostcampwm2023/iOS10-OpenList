//
//  MajorCategoryViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Foundation

protocol MajorCategoryDependency: Dependency {}

final class MajorCategoryComponent: Component<MajorCategoryDependency> { }

protocol MajorCategoryFactoryable: Factoryable {
	func make(with title: String) -> ViewControllable
}

final class MajorCategoryViewFactory: Factory<MajorCategoryDependency>, MajorCategoryFactoryable {
	override init(parent: MajorCategoryDependency) {
		super.init(parent: parent)
	}
	
	func make(with title: String) -> ViewControllable {
		let router = MajorCategoryRouter()
		let viewModel = MajorCategoryViewModel(title: title)
		let viewController = MajorCategoryViewController(
			router: router,
			viewModel: viewModel
		)
		router.viewController = viewController
		return viewController
	}
}
