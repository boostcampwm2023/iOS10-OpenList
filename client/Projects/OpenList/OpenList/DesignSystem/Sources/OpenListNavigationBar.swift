//
//  OpenListNavigationBar.swift
//  OpenList
//
//  Created by 김영균 on 11/24/23.
//

import UIKit

protocol OpenListNavigationBarDelegate: AnyObject {
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBackButton button: UIButton)
	func openListNavigationBar(
		_ navigationBar: OpenListNavigationBar,
		didTapBarItem item: OpenListNavigationBarItem
	)
}

final class OpenListNavigationBar: UIView {
	enum Constant {
		static let barHeight: CGFloat = 56
		static let horizontalPadding: CGFloat = 20
		static let itemSpacing: CGFloat = 24
	}
	
	// MARK: - Properties
	weak var delegate: OpenListNavigationBarDelegate?
	
	// MARK: - UI Components
	private let leftView: UIStackView = .init()
	private let rightView: UIStackView = .init()
	internal private(set) var backButtonItem: OpenListNavigationBackButtonItem?
	internal private(set) var leftItems: [OpenListNavigationBarItem]?
	internal private(set) var rightItems: [OpenListNavigationBarItem]?
	
	// MARK: - Initializers
	init(
		isBackButtonHidden: Bool = true,
		backButtonTitle: String? = "",
		leftItems: [OpenListNavigationItemType] = [],
		rightItems: [OpenListNavigationItemType] = []
	) {
		self.leftItems = leftItems.map(OpenListNavigationBarItem.init(type:))
		self.rightItems = rightItems.map(OpenListNavigationBarItem.init(type:))
		if !isBackButtonHidden {
			backButtonItem = OpenListNavigationBackButtonItem(backButtonTitle: backButtonTitle)
		}
		
		super.init(
			frame: .init(
				origin: .init(x: 0, y: UIDevice.safeAreaTopHeight),
				size: .init(width: UIScreen.main.bounds.width, height: Constant.barHeight)
			)
		)
		
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - 네비게이션 바 아이템 추가 및 삭제 메서드
extension OpenListNavigationBar {
	func appendLeftItem(_ item: OpenListNavigationBarItem) {
		leftItems?.append(item)
		leftView.addArrangedSubview(item)
	}
	
	func appendRightItem(_ item: OpenListNavigationBarItem) {
		rightItems?.append(item)
		rightView.addArrangedSubview(item)
	}
	
	func insertLeftItem(_ item: OpenListNavigationBarItem, at index: Int) {
		leftItems?.insert(item, at: index)
		leftView.insertArrangedSubview(item, at: index)
	}
	
	func insertRightItem(_ item: OpenListNavigationBarItem, at index: Int) {
		rightItems?.insert(item, at: index)
		rightView.insertArrangedSubview(item, at: index)
	}
	
	func removeLeftItem(_ item: OpenListNavigationBarItem) {
		leftItems?.removeAll(where: { $0 == item })
		leftView.removeArrangedSubview(item)
	}
	
	func removeRightItem(_ item: OpenListNavigationBarItem) {
		rightItems?.removeAll(where: { $0 == item })
		rightView.removeArrangedSubview(item)
	}
}

// MARK: - UI 관련 메서드
private extension OpenListNavigationBar {
	// MARK: View Attributes
	func setViewAttributes() {
		backgroundColor = .background
		setLeftViewAttributes()
		setRightViewAttributes()
		setActionAttributes()
	}
	
	func setLeftViewAttributes() {
		leftView.translatesAutoresizingMaskIntoConstraints = false
		leftView.axis = .horizontal
		leftView.alignment = .center
		leftView.spacing = 24
	}
	
	func setRightViewAttributes() {
		rightView.translatesAutoresizingMaskIntoConstraints = false
		rightView.axis = .horizontal
		rightView.alignment = .center
		rightView.spacing = 24
	}
	
	func setActionAttributes() {
		backButtonItem?.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
		leftItems?.forEach {
			$0.addTarget(self, action: #selector(didTapBarItem), for: .touchUpInside)
		}
		rightItems?.forEach {
			$0.addTarget(self, action: #selector(didTapBarItem), for: .touchUpInside)
		}
	}
	
	// MARK: View Hierarchies
	func setViewHierarchies() {
		if let backButtonItem = backButtonItem {
			leftView.addArrangedSubview(backButtonItem)
		}
		if let leftItems = leftItems {
			leftItems.forEach(leftView.addArrangedSubview)
		}
		if let rightItems = rightItems {
			rightItems.forEach(rightView.addArrangedSubview)
		}
		addSubview(leftView)
		addSubview(rightView)
	}
	
	// MARK: View Constratins
	func setViewConstraints() {
		setLeftViewConstraints()
		setRightViewConstraints()
	}
	
	func setLeftViewConstraints() {
		NSLayoutConstraint.activate([
			leftView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constant.horizontalPadding),
			leftView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
		
		if let leftItems = leftItems {
			leftItems.forEach {
				$0.translatesAutoresizingMaskIntoConstraints = false
				if let textWidth = $0.titleLabel?.intrinsicContentSize.width {
					$0.widthAnchor.constraint(equalToConstant: 24 + textWidth).isActive = true
				} else {
					$0.widthAnchor.constraint(equalToConstant: 24).isActive = true
				}
				$0.heightAnchor.constraint(equalToConstant: 24).isActive = true
			}
		}
	}
	
	func setRightViewConstraints() {
		NSLayoutConstraint.activate([
			rightView.leadingAnchor.constraint(
				greaterThanOrEqualTo: leftView.trailingAnchor,
				constant: Constant.itemSpacing
			),
			rightView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constant.horizontalPadding),
			rightView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
		
		if let rightItems = rightItems {
			rightItems.forEach {
				$0.translatesAutoresizingMaskIntoConstraints = false
				$0.widthAnchor.constraint(equalToConstant: 24).isActive = true
				$0.heightAnchor.constraint(equalToConstant: 24).isActive = true
			}
		}
	}
	
	// MARK: View Action Methods
	@objc func didTapBackButton(_ button: UIButton) {
		delegate?.openListNavigationBar(self, didTapBackButton: button)
	}
	
	@objc func didTapBarItem(_ item: OpenListNavigationBarItem) {
		delegate?.openListNavigationBar(self, didTapBarItem: item)
	}
}
