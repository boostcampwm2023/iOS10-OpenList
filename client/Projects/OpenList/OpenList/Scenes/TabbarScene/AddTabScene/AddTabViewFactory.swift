//
//  AddTabViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/10/23.
//

import Foundation

protocol AddTabDependency: Dependency {}

final class AddTabComponent: Component<AddTabDependency> {}

protocol AddTabFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class AddTabViewFactory: Factory<AddTabDependency>, AddTabFactoryable {
	override init(parent: AddTabDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let router = AddTabRouter()
		let viewController = AddTabViewController(router: router)
		router.viewController = viewController
		return viewController
	}
}
