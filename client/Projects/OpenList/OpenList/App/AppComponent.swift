//
//  AppComponent.swift
//  OpenList
//
//  Created by 김영균 on 11/11/23.
//

import Foundation

final class AppComponent: EmptyComponent, TabBarDependency {
	var navigationControllable: NavigationControllable
	var persistenceRepository: PersistenceRepository {
		return DefaultPersistenceRepository(coreDataStorage: coreDataStorage)
	}
	var coreDataStorage: CoreDataStorage {
		return CoreDataStorage.shared
	}
	
	init(navigationControllable: NavigationControllable) {
		self.navigationControllable = navigationControllable
	}
}
