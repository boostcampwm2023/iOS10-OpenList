//
//  Factoryable.swift
//  OpenList
//
//  Created by 김영균 on 11/10/23.
//

import Foundation

protocol Factoryable: AnyObject { }

class Factory<ParentDependencyType> {
	let parent: ParentDependencyType
	
	init(parent: ParentDependencyType) {
		self.parent = parent
	}
}
