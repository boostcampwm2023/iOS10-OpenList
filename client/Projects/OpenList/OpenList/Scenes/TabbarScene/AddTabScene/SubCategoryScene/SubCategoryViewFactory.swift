//
//  SubCategoryViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/29/23.
//

import Foundation

protocol SubCategoryDependency: Dependency { }

final class SubCategoryComponent: Component<SubCategoryDependency>, MinorCategoryDependency {
	fileprivate var minorCategoryFactory: MinorCategoryFactoryable {
		return MinorCategoryViewFactory(parent: self)
	}
}

protocol SubCategoryFactoryable: Factoryable {
	func make(with category: Category) -> ViewControllable
}

final class SubCategoryViewFactory: Factory<SubCategoryDependency>, SubCategoryFactoryable {
	override init(parent: SubCategoryDependency) {
		super.init(parent: parent)
	}
	
	func make(with category: Category) -> ViewControllable {
		let component = SubCategoryComponent(parent: parent)
		let router = SubCategoryRouter(minorCategoryFactory: component.minorCategoryFactory)
		let viewModel = SubCategoryViewModel(categoryInfo: category)
		let viewController = SubCategoryViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
