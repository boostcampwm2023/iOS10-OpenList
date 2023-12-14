//
//  CheckListFolderViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import Foundation

protocol CheckListFolderDependency: Dependency { }

final class CheckListFolderComponent: Component<CheckListFolderDependency> { }

protocol CheckListFolderFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class CheckListFolderViewFactory: Factory<CheckListFolderDependency>, CheckListFolderFactoryable {
	override init(parent: CheckListFolderDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let router = CheckListFolderRouter()
		let viewModel = CheckListFolderViewModel()
		let viewController = CheckListFolderViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
