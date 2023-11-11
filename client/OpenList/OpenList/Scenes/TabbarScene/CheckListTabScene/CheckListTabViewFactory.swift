//
//  CheckListTabViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/10/23.
//

import Foundation

protocol CheckListTabDependency: Dependency {}

final class CheckListTabComponent: Component<CheckListTabDependency> {}

protocol CheckListTabFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class CheckListTabViewFactory: CheckListTabFactoryable {
	private let component: CheckListTabComponent
	
	init(component: CheckListTabComponent){
		self.component = component
	}
	
	func make() -> ViewControllable {
		let router = CheckListTabRouter()
		let viewController = CheckListTabViewController(router: router)
		return viewController
	}
}
