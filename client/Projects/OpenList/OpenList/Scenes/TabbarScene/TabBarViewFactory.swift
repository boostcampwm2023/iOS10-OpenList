//
//  TabBarViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import Combine
import Foundation

protocol TabBarDependency: Dependency {
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> { get }
}

final class TabBarComponent:
	Component<TabBarDependency>,
	CheckListTableDependency,
	AddTabDependency,
	RecommendTabDependency {
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> {
		return parent.deepLinkSubject
	}
	
	var validCheckUseCase: ValidCheckUseCase {
		return DefaultValidCheckUseCase()
	}
	
	var persistenceUseCase: PersistenceUseCase {
		return DefaultPersistenceUseCase(checkListRepository: checkListRepository)
	}
	
	var checkListRepository: CheckListRepository {
		return DefaultCheckListRepository(checkListStorage: checkListStorage)
	}
	
	var checkListStorage: CheckListStorage {
		return DefaultCheckListStorage()
	}
	
	fileprivate var addTabFactoryable: AddTabFactoryable {
		return AddTabViewFactory(parent: self)
	}
	
	fileprivate var checklistTabFactoryable: CheckListTableFactoryable {
		return CheckListTableViewFactory(parent: self)
	}
	
	fileprivate var recommendTabFactoryable: RecommendTabFactoryable {
		return RecommendTabViewFactory(parent: self)
	}
}

protocol TabBarFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class TabBarViewFactory: Factory<TabBarDependency>, TabBarFactoryable {
	override init(parent: TabBarDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let component = TabBarComponent(parent: parent)
		let tabBarViewController = TabBarViewController(
			checkListTabFactoryable: component.checklistTabFactoryable,
			addTabFactoryable: component.addTabFactoryable,
			recommendTabFactoryable: component.recommendTabFactoryable
		)
		return tabBarViewController
	}
}
