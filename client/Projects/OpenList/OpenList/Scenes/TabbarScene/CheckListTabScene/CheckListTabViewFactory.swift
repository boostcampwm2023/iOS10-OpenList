//
//  CheckListTabViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import Combine
import Foundation

protocol CheckListTabDependency: Dependency {
	var persistenceUseCase: PersistenceUseCase { get }
	var checkListRepository: CheckListRepository { get }
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> { get }
}

final class CheckListTabComponent:
	Component<CheckListTabDependency>,
	CheckListFolderDependency,
	CheckListTableDependency {
	var persistenceUseCase: PersistenceUseCase { parent.persistenceUseCase }
	
	var checkListRepository: CheckListRepository { parent.checkListRepository }
	
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> { parent.deepLinkSubject }
	
	fileprivate var checkListFolderFactoryable: CheckListFolderFactoryable {
		return CheckListFolderViewFactory(parent: self)
	}
	
	fileprivate var checkListTableFactoryable: CheckListTableFactoryable {
		return CheckListTableViewFactory(parent: self)
	}
}

protocol CheckListTabFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class CheckListTabViewFactory: Factory<CheckListTabDependency>, CheckListTabFactoryable {
	override init(parent: CheckListTabDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let component = CheckListTabComponent(parent: parent)
		let viewController = CheckListTabViewController(
			checkListFolderFactory: component.checkListFolderFactoryable,
			checkListTableFactory: component.checkListTableFactoryable
		)
		return viewController
	}
}
