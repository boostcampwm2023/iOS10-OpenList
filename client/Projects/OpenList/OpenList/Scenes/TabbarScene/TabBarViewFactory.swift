//
//  TabBarViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import Foundation

protocol TabBarDependency: Dependency {
	var persistenceRepository: PersistenceRepository { get }
}

final class TabBarComponent:
	Component<TabBarDependency>,
	CheckListTableDependency,
	AddTabDependency,
	RecommendTabDependency {
	var validCheckUseCase: ValidCheckUseCase {
		return DefaultValidCheckUseCase()
	}
	
	var persistenceUseCase: PersistenceUseCase {
		return DefaultPersistenceUseCase(persistenceRepository: parent.persistenceRepository)
	}
	
	var sampleRepository: SampleRepository {
		return DefaultSampleRepository()
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
			checkListTabViewControllable: component.checklistTabFactoryable.make(),
			addTabViewControllable: component.addTabFactoryable.make(),
			recommendTabViewControllable: component.recommendTabFactoryable.make()
		)
		return tabBarViewController
	}
}
