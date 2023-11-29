//
//  MinorCategoryViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

protocol MinorCategoryDependency: Dependency {}

final class MinorCategoryComponent: Component<MinorCategoryDependency> {}

protocol MinorCategoryFactoryable: Factoryable {
	func make(with category: Category) -> ViewControllable
}

final class MinorCategoryViewFactory: Factory<MinorCategoryDependency>, MinorCategoryFactoryable {
	override init(parent: MinorCategoryDependency) {
		super.init(parent: parent)
	}
	
	func make(with category: Category) -> ViewControllable {
		let router = MinorCategoryRouter()
		let viewModel = MinorCategoryViewModel(categoryInfo: category)
		let viewController = MinorCategoryViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
