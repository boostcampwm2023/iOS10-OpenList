//
//  AddCheckListTitleViewFactory.swift
//  OpenList
//
//  Created by Hoon on 11/15/23.
//

import CustomNetwork
import Foundation

protocol AddCheckListTitleDependency: Dependency {
	var validCheckUseCase: ValidCheckUseCase { get }
	var persistenceUseCase: PersistenceUseCase { get }
}

final class AddCheckListTitleComponent:
	Component<AddCheckListTitleDependency>,
	MainCategoryDependency {
	var categoryUseCase: CategoryUseCase {
		return DefaultCategoryUseCase(categoryRepository: categoryRepository)
	}
	
	var categoryRepository: CategoryRepository {
		return DefaultCategoryRepository(session: categorySession)
	}
	
	var categorySession: CustomSession {
		return CustomSession(
			configuration: .default,
			interceptor: AccessTokenInterceptor()
		)
	}
	
	fileprivate var validCheckUseCase: ValidCheckUseCase {
		return parent.validCheckUseCase
	}
	
	fileprivate var persistenceUseCase: PersistenceUseCase {
		return parent.persistenceUseCase
	}
	
	fileprivate var mainCategoryFactoryable: MainCategoryFactoryable {
		return MainCategoryViewFactory(parent: self)
	}
}

protocol AddCheckListTitleFactoryable: Factoryable {
	func make() -> ViewControllable
}

final class AddCheckListTitleViewFactory: Factory<AddCheckListTitleDependency>, AddCheckListTitleFactoryable {
	override init(parent: AddCheckListTitleDependency) {
		super.init(parent: parent)
	}
	
	func make() -> ViewControllable {
		let component = AddCheckListTitleComponent(parent: parent)
		let router = AddCheckListTitleRouter(
			mainCategoryViewFactory: component.mainCategoryFactoryable
		)
		let viewModel = AddCheckListTitleViewModel(
			validCheckUseCase: component.validCheckUseCase,
			persistenceUseCase: component.persistenceUseCase
		)
		let viewController = AddCheckListTitleViewController(router: router, viewModel: viewModel)
		router.viewController = viewController
		return viewController
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
