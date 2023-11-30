//
//  AddCheckListItemViewFactory.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import Foundation

protocol AddCheckListItemDependency: Dependency { }

final class AddCheckListItemComponent: Component<AddCheckListItemDependency> { }

protocol AddCheckListItemFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class AddCheckListItemViewFactory: Factory<AddCheckListItemDependency>, AddCheckListItemFactoryable {
	override init(parent: AddCheckListItemDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let router = AddCheckListItemRouter()
		let viewModel = AddCheckListItemViewModel()
		let viewController = AddCheckListItemViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
