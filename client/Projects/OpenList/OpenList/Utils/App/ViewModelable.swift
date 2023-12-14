//
//  ViewModelable.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Combine

protocol ViewModelable {
	associatedtype Input
	associatedtype State
	associatedtype Output
	
	func transform(_ input: Input) -> Output
}
