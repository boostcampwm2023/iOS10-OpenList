//
//  UICollectionView+Extensions.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import UIKit

extension UICollectionView {
	/// 컬렉션 뷰에 셀을 등록합니다.
	/// - Parameter type: 셀의 타입입니다. (예: `MyCell.self`)
	func registerCell<T: UICollectionViewCell>(_ type: T.Type) {
		let identifier = String(describing: type)
		register(T.self, forCellWithReuseIdentifier: identifier)
	}
	
	/// 컬렉션 뷰의 셀을 재사용합니다.
	/// - Parameters:
	///   - type: 셀의 타입입니다. (예: `MyCell.self`)
	///   - indexPath: 셀의 인덱스 경로입니다.
	func dequeueCell<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
		let identifier = String(describing: type)
		guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
			fatalError("identifier: \(identifier) could not be dequeued as \(T.self)")
		}
		return cell
	}
	
	/// 컬렉션 뷰의 헤더를 등록합니다.
	/// - Parameter type: 헤더의 타입입니다. (예: `MyHeader.self`)
	func registerHeader<T: UICollectionReusableView>(_ type: T.Type) {
		let identifier = String(describing: type)
		register(
			type,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: identifier
		)
	}
	
	/// 컬렉션 뷰의 헤더를 재사용합니다.
	/// - Parameters:
	///   - type: 헤더의 타입입니다. (예: `MyHeader.self`)
	///   - indexPath: 헤더의 인덱스 경로입니다.
	func dequeueHeader<T: UICollectionReusableView>(_ type: T.Type, for indexPath: IndexPath) -> T {
		let identifier = String(describing: type)
		guard let header = dequeueReusableSupplementaryView(
			ofKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: identifier,
			for: indexPath
		) as? T else {
			fatalError("identifier: \(identifier) could not be dequeued as \(T.self)")
		}
		return header
	}
	
	/// 컬렉션 뷰의 푸터를 등록합니다.
	/// - Parameter type: 푸터의 타입입니다. (예: `MyHeader.self`)
	func registerFooter<T: UICollectionReusableView>(_ type: T.Type) {
		let identifier = String(describing: type)
		register(
			type,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
			withReuseIdentifier: identifier
		)
	}
	
	/// 컬렉션 뷰의 푸터를 재사용합니다.
	/// - Parameters:
	///   - type: 푸터의 타입입니다. (예: `MyHeader.self`)
	///   - indexPath: 푸터의 인덱스 경로입니다.
	func dequeueFooter<T: UICollectionReusableView>(_ type: T.Type, for indexPath: IndexPath) -> T {
		let identifier = String(describing: type)
		guard let footer = dequeueReusableSupplementaryView(
			ofKind: UICollectionView.elementKindSectionFooter,
			withReuseIdentifier: identifier,
			for: indexPath
		) as? T else {
			fatalError("identifier: \(identifier) could not be dequeued as \(T.self)")
		}
		return footer
	}
}
