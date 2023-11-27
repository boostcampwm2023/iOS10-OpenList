//
//  AppComponent.swift
//  OpenList
//
//  Created by 김영균 on 11/11/23.
//

import Foundation

final class AppComponent: EmptyComponent, TabBarDependency {
	var navigationControllable: NavigationControllable
	var coreDataStorage: CoreDataStorage {
		return CoreDataStorage.shared
	}
	
	init(navigationControllable: NavigationControllable) {
		self.navigationControllable = navigationControllable
	}
}

final class AppLoginComponent: EmptyComponent, LoginDependency {
	var navigationControllable: NavigationControllable
	
	var loginUseCase: AuthUseCase {
		return DefaultAuthUseCase(defaultAuthRepository: defaultAuthRepository)
	}
	
	var defaultAuthRepository: AuthRepository {
		return DefaultAuthRepository()
	}
	
	init(navigationControllable: NavigationControllable) {
		self.navigationControllable = navigationControllable
	}
}
