//
//  AppComponent.swift
//  OpenList
//
//  Created by 김영균 on 11/11/23.
//

import Combine
import Foundation

final class AppComponent: EmptyComponent, TabBarDependency {
	var navigationControllable: NavigationControllable
	private var _deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never>
	
	var deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never> { _deepLinkSubject }
	var coreDataStorage: CoreDataStorage {
		return CoreDataStorage.shared
	}
	
	init(
		navigationControllable: NavigationControllable,
		deepLinkSubject: PassthroughSubject<DeepLinkTarget, Never>
	) {
		self.navigationControllable = navigationControllable
		self._deepLinkSubject = deepLinkSubject
	}
}
