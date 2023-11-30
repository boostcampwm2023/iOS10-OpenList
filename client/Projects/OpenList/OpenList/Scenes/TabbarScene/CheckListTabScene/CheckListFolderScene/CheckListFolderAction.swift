//
//  CheckListFolderAction.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import Combine

struct CheckListFolderInput {
	let viewWillAppear: PassthroughSubject<Void, Never>
}

enum CheckListFolderState {
	case folders([CheckListFolderItem])
	case error(Error)
}
