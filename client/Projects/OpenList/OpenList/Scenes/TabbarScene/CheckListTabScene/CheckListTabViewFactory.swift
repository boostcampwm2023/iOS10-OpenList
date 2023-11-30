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
	CheckListTableDependency,
	WithCheckListDependency,
	SharedCheckListDependency {
	var crdtStorage: CRDTStorage = DefaultCRDTStorage()
	
	var crdtRepository: CRDTRepository { DefaultCRDTRepository(crdtStorage: crdtStorage) }
	
	var persistenceUseCase: PersistenceUseCase { parent.persistenceUseCase }
	
	var checkListRepository: CheckListRepository { parent.checkListRepository }
	
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> { parent.deepLinkSubject }
	
	fileprivate var privateCheckListTableFactoryable: CheckListTableFactoryable {
		return CheckListTableViewFactory(parent: self)
	}
	
	fileprivate var withCheckListFactoryable: WithCheckListFactoryable {
		return WithCheckListViewFactory(parent: self)
	}
	
	fileprivate var sharedCheckListFactoryable: SharedCheckListFactoryable {
		return SharedCheckListViewFactory(parent: self)
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
			privateCheckListTableFactory: component.privateCheckListTableFactoryable,
			withCheckListFactoryable: component.withCheckListFactoryable,
			sharedCheckListFactory: component.sharedCheckListFactoryable
		)
		return viewController
	}
}
