//
//  CheckListTabViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import Combine
import CustomNetwork
import Foundation

protocol CheckListTabDependency: Dependency {
	var session: CustomSession { get }
	var checkListStorage: PrivateCheckListStorage { get }
	var persistenceUseCase: PersistenceUseCase { get }
	var checkListRepository: CheckListRepository { get }
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> { get }
}

final class CheckListTabComponent:
	Component<CheckListTabDependency>,
	CheckListTableDependency,
	WithCheckListDependency,
	SharedCheckListDependency,
	ProfileDependency,
	SettingDependency {
	var session: CustomSession { parent.session }
	
	var crdtStorage: CRDTStorage = DefaultCRDTStorage()
	
	var crdtRepository: CRDTRepository { DefaultCRDTRepository(crdtStorage: crdtStorage) }
	
	var persistenceUseCase: PersistenceUseCase { parent.persistenceUseCase }
	
	var checkListStorage: PrivateCheckListStorage { parent.checkListStorage }
	
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
	
	fileprivate var profileFactoryable: ProfileFactoryable {
		return ProfileViewFactory(parent: self)
	}
	
	fileprivate var settingFactoryable: SettingFactoryable {
		return SettingViewFactory(parent: self)
	}
}

protocol CheckListTabFactoryable: Factoryable {
	func make(with appRouter: AppRouterProtocol) -> ViewControllable
}

final class CheckListTabViewFactory: Factory<CheckListTabDependency>, CheckListTabFactoryable {
	override init(parent: CheckListTabDependency) {
		super.init(parent: parent)
	}
	
	func make(with appRouter: AppRouterProtocol) -> ViewControllable {
		let component = CheckListTabComponent(parent: parent)
		let router = CheckListTabRouter(
			appRouter: appRouter,
			profileFactory: component.profileFactoryable,
			settingFactory: component.settingFactoryable
		)
		let viewController = CheckListTabViewController(
			router: router,
			privateCheckListTableFactory: component.privateCheckListTableFactoryable,
			withCheckListFactoryable: component.withCheckListFactoryable,
			sharedCheckListFactory: component.sharedCheckListFactoryable
		)
		router.viewController = viewController
		return viewController
	}
}
