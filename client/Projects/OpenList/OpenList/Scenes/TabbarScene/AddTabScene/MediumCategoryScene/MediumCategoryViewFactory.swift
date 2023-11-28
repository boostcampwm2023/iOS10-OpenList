//
//  MediumCategoryViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

protocol MediumCategoryDependency: Dependency { }

final class MediumCategoryComponent: Component<MediumCategoryDependency> {}

protocol MediumCategoryFactoryable: Factoryable {
	func make(with category: String) -> ViewControllable
}

final class MediumCategoryViewFactory: Factory<MediumCategoryDependency>, MediumCategoryFactoryable {
	override init(parent: MediumCategoryDependency) {
		super.init(parent: parent)
	}
	
	func make(with category: String) -> ViewControllable {
		let router = MediumCategoryRouter()
		let viewModel = MediumCategoryViewModel(majorCategoryTitle: category)
		let viewController = MediumCategoryViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
