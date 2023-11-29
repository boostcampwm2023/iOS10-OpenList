//
//  TabBarViewFactory.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import Combine
import Foundation
import CustomNetwork

protocol TabBarDependency: Dependency {
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> { get }
}

final class TabBarComponent:
	Component<TabBarDependency>,
	CheckListTabDependency,
	AddCheckListTitleDependency,
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
	
	var categoryUseCase: CategoryUseCase {
		return DefaultCategoryUseCase(categoryRepository: categoryRepository)
	}
	
	var categoryRepository: CategoryRepository {
		return DefaultCategoryRepository(session: customSession)
	}
	
	var checkListRepository: CheckListRepository {
		return DefaultCheckListRepository(checkListStorage: checkListStorage)
	}
	
	var checkListStorage: PrivateCheckListStorage {
		return DefaultPrivateCheckListStorage()
	}
	
	var customSession: CustomSession {
		return CustomSession(
			configuration: .default,
			interceptor: AccessTokenInterceptor()
		)
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

final class AccessTokenInterceptor: RequestInterceptor {
	public func intercept(_ request: URLRequest) -> URLRequest {
		var request = request
		if let accessToken = KeyChain.shared.read(key: AuthKey.accessToken) {
			request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
			return request
		} else {
			return request
		}
	}
}
