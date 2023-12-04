//
//  Future+.swift
//  OpenList
//
//  Created by wi_seong on 11/16/23.
//

import Combine

extension Future where Failure == Never {
	convenience init(asyncFunc: @escaping () async throws -> Output) {
		self.init { promise in
			Task {
				do {
					let result = try await asyncFunc()
					promise(.success(result))
				} catch {
//					dump(error)
				}
			}
		}
	}
}
