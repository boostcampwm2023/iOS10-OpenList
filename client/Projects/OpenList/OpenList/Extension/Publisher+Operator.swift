//
//  Publisher+Operator.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import Combine

extension Publisher {
	func withUnretained<O: AnyObject>(_ owner: O) -> Publishers.CompactMap<Self, (O, Self.Output)> {
		compactMap { [weak owner] output in
			owner == nil ? nil : (owner!, output)
		}
	}
}
