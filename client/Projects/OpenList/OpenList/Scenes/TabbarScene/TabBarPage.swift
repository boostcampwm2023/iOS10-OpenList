//
//  TabBarPage.swift
//  OpenList
//
//  Created by 김영균 on 11/9/23.
//

import Foundation

enum TabBarPage: String, CaseIterable {
	case checklistTab
	case addTab
	case recommendTab
	
	init?(index: Int) {
		switch index {
		case 0: self = .checklistTab
		case 1: self = .addTab
		case 2: self = .recommendTab
		default: return nil
		}
	}
	
	func pageTitleValue() -> String {
		switch self {
		case .checklistTab: return "체크리스트"
		case .addTab: return "추가"
		case .recommendTab: return "추천"
		}
	}
	
	func pageOrderNumber() -> Int {
		switch self {
		case .checklistTab: return 0
		case .addTab: return 1
		case .recommendTab: return 2
		}
	}
	
	func tabIconName() -> String {
		switch self {
		case .checklistTab: return "checklist.tab"
		case .addTab: return "add.tab"
		case .recommendTab: return "recommand.tab"
		}
	}
}
