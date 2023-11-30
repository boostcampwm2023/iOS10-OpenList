//
//  CheckListFolderViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import Foundation

protocol CheckListFolderDependency: Dependency {
	var folderRepository: FolderRepository { get }
}

final class CheckListFolderComponent: Component<CheckListFolderDependency> {
	fileprivate var privateCheckListUseCase: PrivateCheckListUseCase {
		DefaultPrivateCheckListUseCase(folderRepository: parent.folderRepository)
	}
}

protocol CheckListFolderFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class CheckListFolderViewFactory: Factory<CheckListFolderDependency>, CheckListFolderFactoryable {
	override init(parent: CheckListFolderDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let component = CheckListFolderComponent(parent: parent)
		let router = CheckListFolderRouter()
		let viewModel = CheckListFolderViewModel(privateCheckListUseCase: component.privateCheckListUseCase)
		let viewController = CheckListFolderViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
	}
}
