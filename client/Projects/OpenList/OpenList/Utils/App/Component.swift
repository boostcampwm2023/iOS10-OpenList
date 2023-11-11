//
//  Component.swift
//  OpenList
//
//  Created by 김영균 on 11/10/23.
//

import Foundation

class EmptyComponent: EmptyDependency {
	init() {}
}

class Component<ParentDependency>: Parent {
	let parent: ParentDependency
	
	init(parent: ParentDependency) {
		self.parent = parent
	}
}
