//
//  UITableView+Extensions.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import UIKit

public extension UITableView {
	/// 테이블 뷰의 셀을 반환합니다.
	/// - Parameters:
	/// 	- type: 셀의 타입입니다. (예: `MyCell.self`)
	/// 	- indexPath: 셀의 인덱스 경로입니다.
	func cellForRow<T: UITableViewCell>(_ type: T.Type, at indexPath: IndexPath) -> T {
		let identifier = String(describing: type)
		guard let cell = cellForRow(at: indexPath) as? T else {
			fatalError("identifier: \(identifier) could not be row as \(T.self)")
		}
		return cell
	}
	
	/// 테이블 뷰에 셀을 등록합니다.
	/// - Parameter type: 셀의 타입입니다. (예: `MyCell.self`)
	func registerCell<T: UITableViewCell>(_ type: T.Type) {
		let identifier = String(describing: type)
		register(T.self, forCellReuseIdentifier: identifier)
	}
	
	/// 테이블 뷰의 셀을 재사용합니다.
	/// - Parameter type: 셀의 타입입니다. (예: `MyCell.self`)
	func dequeueCell<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
		let identifier = String(describing: type)
		guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
			fatalError("identifier: \(identifier) could not be dequeued as \(T.self)")
		}
		return cell
	}
	
	/// 테이블 뷰에 헤더와 푸터를 등록합니다.
	/// - Parameter type: 헤더와 푸터의 타입입니다. (예: `MyHeaderFooter.self`)
	func registerHeaderFooter<T: UITableViewHeaderFooterView>(_ type: T.Type) {
		let identifier = String(describing: type)
		register(T.self, forHeaderFooterViewReuseIdentifier: identifier)
	}
	
	/// 테이블 뷰의 헤더와 푸터를 재사용합니다.
	/// - Parameter type: 헤더와 푸터의 타입입니다. (예: `MyHeaderFooter.self`)
	func dequeueHeaderFooter<T: UITableViewHeaderFooterView>(_ type: T.Type) -> T {
		let identifier = String(describing: type)
		guard let headerFooter = dequeueReusableHeaderFooterView(withIdentifier: identifier) as? T else {
			fatalError("identifier: \(identifier) could not be dequeued as \(T.self)")
		}
		return headerFooter
	}
}
