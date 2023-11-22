//
//  VectorClock.swift
//  crdt
//
//  Created by wi_seong on 11/19/23.
//

import Foundation

final class VectorClock: Codable {
	private var clock: [Int: Int]
	
	init() {
		clock = [:]
	}
	
	init(_ siteVectorClock: VectorClock) {
		clock = siteVectorClock.clock
	}
	
	subscript(safe replica: Int) -> Int {
		get {
			return clock[replica, default: 0]
		}
		set {
			clock[replica] = newValue
		}
	}
}

extension VectorClock {
	/// 벡터 시계가 합쳐질 조건
	/// `VectorClock[r] == O[r] - 1 && ∀i ∈ {1, 2, ..., n}: if i ≠ r: Vecto≥≥rClock[i] ≥ O[i]`
	/// - Parameters:
	///  - r: 벡터 시계의 키값
	///  - O: 합칠 벡터 시계
	/// - Returns: 합칠 조건이 맞으면 true, 아니면 false
	func readyFor(replica: Int, to vectorClock: VectorClock) -> Bool {
		if self[safe: replica] != vectorClock.clock[replica]! - 1 {
			return false
		}
		for (key, value) in vectorClock.clock {
			if key != replica && self[safe: key] < value {
				return false
			}
		}
		return true
	}
	
	/// 모든 엔트리의 합을 반환한다.
	var sum: Int {
		return clock.values.reduce(0, +)
	}
	
	/// 레플리카 r을 키값으로 갖는 엔트리를 1 증가시킨다.
	func increase(_ replica: Int) {
		clock[replica, default: 0] += 1
	}
	
	/// 레플리카 r을 키값으로 갖는 엔트리를 n 증가시킨다.
	func increase(_ replica: Int, to value: Int) {
		clock[replica, default: 0] += value
	}
}

extension VectorClock: Comparable {
	static func < (lhs: VectorClock, rhs: VectorClock) -> Bool {
		return !(lhs >= rhs)
	}
	
	/// VectorClock > T인지 불린 값을 반환합니다.
	/// 모든 레플리카 i에 대해 ∀i: VectorClock[i] >= T[i], ∃j: VectorClock[j] > T[j]
	static func > (lhs: VectorClock, rhs: VectorClock) -> Bool {
		var greaterThan = false
		for (key, value) in rhs.clock {
			if lhs[safe: key] < value {
				return false
			} else if lhs[safe: key] > value {
				greaterThan = true
			}
		}
		if greaterThan { return true }
		for (key, value) in lhs.clock where rhs[safe: key] < value {
			return true
		}
		return false
	}
	
	static func == (lhs: VectorClock, rhs: VectorClock) -> Bool {
		let keys = Set(lhs.clock.keys).union(rhs.clock.keys)
		for key in keys where lhs[safe: key] != rhs[safe: key] {
			return false
		}
		return true
	}
}

extension VectorClock: Hashable {
	func hash(into hasher: inout Hasher) {
		var hash = 7
		for (key, value) in self.clock {
			hash += 7 * key * value
		}
		hasher.combine(hash)
	}
}

extension VectorClock: CustomDebugStringConvertible {
	var debugDescription: String {
		var desc = "{"
		for (key, value) in self.clock {
			desc += "(\(key),\(value)),"
		}
		desc += "}"
		return desc
	}
}
