//
//  AddCheckListItemViewFactory.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import Foundation

protocol AddCheckListItemDependency: Dependency {
	var categoryUseCase: CategoryUseCase { get }
	var persistenceUseCase: PersistenceUseCase { get }
}

final class AddCheckListItemComponent: Component<AddCheckListItemDependency> { }

protocol AddCheckListItemFactoryable: Factoryable {
	func make(with categoryInfo: CategoryInfo) -> ViewControllable
}

final class AddCheckListItemViewFactory: Factory<AddCheckListItemDependency>, AddCheckListItemFactoryable {
	override init(parent: AddCheckListItemDependency) {
		super.init(parent: parent)
	}
	
	func make(with categoryInfo: CategoryInfo) -> ViewControllable {
		let component = AddCheckListItemComponent(parent: parent)
		let router = AddCheckListItemRouter()
		let viewModel = AddCheckListItemViewModel(
			categoryInfo: categoryInfo,
			categoryUseCase: component.parent.categoryUseCase,
			persistenceUseCase: component.parent.persistenceUseCase
		)
		let viewController = AddCheckListItemViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
