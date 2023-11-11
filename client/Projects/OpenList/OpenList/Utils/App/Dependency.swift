//
//  Dependency.swift
//  OpenList
//
//  Created by 김영균 on 11/10/23.
//

import Foundation

protocol EmptyDependency: AnyObject { }

protocol Dependency: AnyObject { }

protocol Parent: Dependency {
	associatedtype ParentDependency
	var parent: ParentDependency { get }
}
