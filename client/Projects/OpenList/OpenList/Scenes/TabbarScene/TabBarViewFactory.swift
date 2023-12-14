//
//  TabBarViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import Combine
import CustomNetwork
import Foundation

protocol TabBarDependency: Dependency {
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> { get }
}

final class TabBarComponent:
	Component<TabBarDependency>,
	CheckListTabDependency,
	AddCheckListTitleDependency,
	RecommendTabDependency,
	ProfileDependency,
	SettingDependency {
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> {
		return parent.deepLinkSubject
	}
	
	var validCheckUseCase: ValidCheckUseCase {
		return DefaultValidCheckUseCase()
	}
	
	var persistenceUseCase: PersistenceUseCase {
		return DefaultPersistenceUseCase(checkListRepository: checkListRepository)
	}
	
	var categoryUseCase: CategoryUseCase {
		return DefaultCategoryUseCase(categoryRepository: categoryRepository)
	}
		
	var categoryRepository: CategoryRepository {
		return DefaultCategoryRepository(session: session)
	}
	
	var checkListRepository: CheckListRepository {
		return DefaultCheckListRepository(checkListStorage: checkListStorage, session: session)
	}
	
	var checkListStorage: PrivateCheckListStorage {
		return DefaultPrivateCheckListStorage()
	}
	
	var session: CustomSession = .init(
		interceptor: AccessTokenInterceptor(),
		retrier: OAtuhRequestRetrier()
	)
	
	var profileFactoryable: ProfileFactoryable {
		return ProfileViewFactory(parent: self)
	}
	
	var settingFactoryable: SettingFactoryable {
		return SettingViewFactory(parent: self)
	}

	fileprivate var addTabFactoryable: AddCheckListTitleFactoryable {
		return AddCheckListTitleViewFactory(parent: self)
	}
	
	fileprivate var checklistTabFactoryable: CheckListTabFactoryable {
		return CheckListTabViewFactory(parent: self)
	}
	
	fileprivate var recommendTabFactoryable: RecommendTabFactoryable {
		return RecommendTabViewFactory(parent: self)
	}
}

protocol TabBarFactoryable: Factoryable {
	func make(with appRouter: AppRouterProtocol) -> ViewControllable
}

final class TabBarViewFactory: Factory<TabBarDependency>, TabBarFactoryable {
	override init(parent: TabBarDependency) {
		super.init(parent: parent)
	}
	
	func make(with appRouter: AppRouterProtocol) -> ViewControllable {
		let component = TabBarComponent(parent: parent)
		let tabBarViewController = TabBarViewController(
			appRouter: appRouter,
			checkListTabFactoryable: component.checklistTabFactoryable,
			addTabFactoryable: component.addTabFactoryable,
			recommendTabFactoryable: component.recommendTabFactoryable
		)
		return tabBarViewController
	}
}
