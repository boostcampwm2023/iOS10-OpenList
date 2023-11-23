//
//  WebSocketRepository.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import CRDT

protocol WebSocketRepository {
	func send(data: Data)
	func receive() async -> Node
}
