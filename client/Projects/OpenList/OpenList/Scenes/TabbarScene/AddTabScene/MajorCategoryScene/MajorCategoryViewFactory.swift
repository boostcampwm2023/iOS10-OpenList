//
//  MajorCategoryViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/21/23.
//

import Foundation

protocol MajorCategoryDependency: Dependency {}

final class MajorCategoryComponent:
	Component<MajorCategoryDependency>,
	MediumCategoryDependency {
	fileprivate var mediumCategoryFactory: MediumCategoryFactoryable {
		return MediumCategoryViewFactory(parent: self)
	}
}

protocol MajorCategoryFactoryable: Factoryable {
	func make(with title: String) -> ViewControllable
}

final class MajorCategoryViewFactory: Factory<MajorCategoryDependency>, MajorCategoryFactoryable {
	override init(parent: MajorCategoryDependency) {
		super.init(parent: parent)
	}
	
	func make(with title: String) -> ViewControllable {
		let component = MajorCategoryComponent(parent: parent)
		let router = MajorCategoryRouter(mediumCategoryFactory: component.mediumCategoryFactory)
		let viewModel = MajorCategoryViewModel(title: title)
		let viewController = MajorCategoryViewController(
			router: router,
			viewModel: viewModel
		)
		router.viewController = viewController
		return viewController
	}
}
