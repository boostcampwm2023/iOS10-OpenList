//
//  MainCategoryViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Foundation

protocol MainCategoryDependency: Dependency {}

final class MainCategoryComponent:
	Component<MainCategoryDependency>,
	SubCategoryDependency {
	fileprivate var subCategoryFactory: SubCategoryFactoryable {
		return SubCategoryViewFactory(parent: self)
	}
}

protocol MainCategoryFactoryable: Factoryable {
	func make(with title: String) -> ViewControllable
}

final class MainCategoryViewFactory: Factory<MainCategoryDependency>, MainCategoryFactoryable {
	override init(parent: MainCategoryDependency) {
		super.init(parent: parent)
	}
	
	func make(with title: String) -> ViewControllable {
		let component = MainCategoryComponent(parent: parent)
		let router = MainCategoryRouter(subCategoryFactory: component.subCategoryFactory)
		let viewModel = MainCategoryViewModel(title: title)
		let viewController = MainCategoryViewController(
			router: router,
			viewModel: viewModel
		)
		router.viewController = viewController
		return viewController
	}
}
