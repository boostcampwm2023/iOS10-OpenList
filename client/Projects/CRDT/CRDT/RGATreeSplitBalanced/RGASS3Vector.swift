//
//  RGASS3Vector.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

// RGA identifier
struct RGASS3Vector: Codable {
	/// upstream peer ID
	var sid: Int
	
	/// sum of the upstream vector clock value during insertion
	/// 식별자 A가 B를 선행한다고 말하면`(A < B)`, `sumA < sumB` 또는 `sumA = sumB ∧ sidA < sidB`이다.
	var sum: Int
	
	/// 최초로 삽입된 노드 내에서 오프셋
	/// 기본 값은 0
	var offset: Int
	
	// MARK: - 생성자  Constructors
	init(sid: Int, sum: Int, offset: Int) {
		self.sid = sid
		self.sum = sum
		self.offset = offset
	}
	
	init(sid: Int, vectorClock: VectorClock, offset: Int) {
		self.init(sid: sid, sum: vectorClock.sum, offset: offset)
	}
	
	func clone() -> RGASS3Vector {
		return self
	}
}

extension RGASS3Vector: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(sid)
		hasher.combine(sum)
		hasher.combine(offset)
	}
	
	static func == (lhs: RGASS3Vector, rhs: RGASS3Vector) -> Bool {
		return lhs.sid == rhs.sid && lhs.sum == rhs.sum && lhs.offset == rhs.offset
	}
}

extension RGASS3Vector: Comparable {
	static func <(lhs: RGASS3Vector, rhs: RGASS3Vector) -> Bool {
		if lhs.sum != rhs.sum {
			return lhs.sum < rhs.sum
		} else {
			return lhs.sid < rhs.sid
		}
	}
}

extension RGASS3Vector: CustomDebugStringConvertible {
	var debugDescription: String {
		return "[\(sid), \(sum), \(offset)]"
	}
}
