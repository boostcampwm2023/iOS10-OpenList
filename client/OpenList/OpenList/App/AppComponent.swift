//
//  AppComponent.swift
//  OpenList
//
//  Created by 김영균 on 11/11/23.
//

import Foundation

final class AppComponent: EmptyComponent, TabBarDependency { 
	var navigationControllable: NavigationControllable
	
	init(navigationControllable: NavigationControllable) {
		self.navigationControllable = navigationControllable
	}
}
