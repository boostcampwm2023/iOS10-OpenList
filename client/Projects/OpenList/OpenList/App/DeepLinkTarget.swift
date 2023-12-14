//
//  DeepLinkTarget.swift
//  OpenList
//
//  Created by 김영균 on 11/23/23.
//

import Foundation

enum DeepLinkTarget {
	/// openlist://shared-checklists?shared-checklistId=\(id)
	case routeToSharedCheckList(id: UUID)
}
