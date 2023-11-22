//
//  RGASNode.swift
//  crdt
//
//  Created by wi_seong on 11/18/23.
//

import Foundation

public final class RGASNode<T: Codable & Equatable>: Codable {
	/// identificer
	private(set) var key: RGASS3Vector?
	
	/// 다음 참조 노드
	var next: RGASNode?
	
	/// SplitLink 노드를 분할한 결과에서 모든 노드에 빠르게 접근하는 것을 도와준다.
	/// 이 값은 노드가 두 부분으로 분할될 때 생긴다.
	var link: RGASNode?
	
	/// idNode
	var tree: RGASTree<T>?
	
	/// 컨텐츠
	var content: [T]?
	
	/// 노드의 컨텐츠 길이.
	/// 노드가 툼스톤이 되면 콘텐츠는 nil이지만 노드의 길이는 살아있다.
	/// 툼스톤을 분할하고 동시 작업을 처리하는데 사용된다.
	var size: Int
	
	/// 툼스톤 플래그
	var tomb: Bool
	
	var offset: Int {
		get { return key?.offset ?? 0 }
		set { key?.offset = newValue }
	}
	
	var isVisible: Bool {
		return !tomb
	}
	
	// Constructors
	init(key: RGASS3Vector?, next: RGASNode?, link: RGASNode?, content: [T]?, tomb: Bool, tree: RGASTree<T>?) {
		self.key = key
		self.next = next
		self.link = link
		self.content = content
		self.size = content?.count ?? 0
		self.tomb = tomb
		self.tree = tree
	}
	
	convenience init() {
		self.init(key: nil, next: nil, link: nil, content: nil, tomb: true, tree: nil)
	}
	
	convenience init(s3v: RGASS3Vector, content: [T]) {
		self.init(key: s3v, next: nil, link: nil, content: content, tomb: false, tree: nil)
	}
	
	convenience init(node: RGASNode, content: [T]?, offset: Int) {
		self.init(key: node.key?.clone(), next: node.next, link: node.link, content: content, tomb: node.tomb, tree: node.tree)
		self.key?.offset = offset
	}
	
	func clone() -> RGASNode {
		return RGASNode(key: key, next: next, link: link, content: content, tomb: tomb, tree: tree)
	}
}

/// ? need?
extension RGASNode: Hashable {
	public static func == (lhs: RGASNode, rhs: RGASNode) -> Bool {
		return lhs.key == rhs.key
	}
	
	public func hash(into hasher: inout Hasher) {
		var hash = 3
		hash = 89 * hash + (key != nil ? key!.hashValue : 0)
		hasher.combine(key)
	}
}

extension RGASNode {
	func makeTombstone() {
		tomb = true
		content = nil
		tree = nil
	}
	
	func getNextVisible() -> RGASNode? {
		var node = next
		while node != nil && !node!.isVisible {
			node = node?.next
		}
		return node
	}
	
	func getLinkVisible() -> RGASNode? {
		var node = link
		while node != nil && !node!.isVisible {
			node = node?.link
		}
		return node
	}
}

extension RGASNode: CustomDebugStringConvertible {
	// toString, getContentAsString, equals, makeTombstone, getNextVisible, getLinkVisible and hashCode
	public var debugDescription: String {
		let nextKey = next?.key?.debugDescription ?? "nil"
		let linkKey = link?.key?.debugDescription ?? "nil"
		return "[\(key), \(nextKey), \(linkKey), \(tomb), \(content), \(size)]"
	}
	
	func getContentAsString() -> String {
		return content?.map { "\($0)" }.joined() ?? ""
	}
}
