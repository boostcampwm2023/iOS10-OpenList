//
//  CheckListTopTabView.swift
//  OpenList
//
//  Created by 김영균 on 11/28/23.
//

import UIKit

protocol CheckListTopTabViewDelegate: AnyObject {
	func checkListTopTabView(
		_ checkListTopTabView: CheckListTopTabView,
		tabDidSelect tab: CheckListTabType
	)
}

final class CheckListTopTabView: UIView {
	// MARK: - Properties
	weak var delegate: CheckListTopTabViewDelegate?
	private(set) var selectedTab: CheckListTabType = .privateTab {
		didSet {
			updateTabButtonColor()
		}
	}
	
	// MARK: - UI Compoenents
	public private(set) var privateTabButton: UIButton = .init()
	public private(set) var withTabButton: UIButton = .init()
	public private(set) var sharedTabButton: UIButton = .init()
	
	// MARK: - Initializers
	init() {
		super.init(frame: .zero)
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension CheckListTopTabView {
	func setSelectedTab(_ tab: CheckListTabType) {
		selectedTab = tab
	}
}

private extension CheckListTopTabView {
	func setViewAttributes() {
		setPrivateTabButtonAttributes()
		setWithTabButtonAttributes()
		setSharedTabButtonAttributes()
	}
	
	func setPrivateTabButtonAttributes() {
		privateTabButton.setTitle("개인", for: .normal)
		privateTabButton.titleLabel?.font = .notoSansCJKkr(type: .medium, size: .medium)
		privateTabButton.setTitleColor(.primary1, for: .normal)
		privateTabButton.addTarget(self, action: #selector(privateTabButtonDidTap), for: .touchUpInside)
		privateTabButton.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setWithTabButtonAttributes() {
		withTabButton.setTitle("함께", for: .normal)
		withTabButton.titleLabel?.font = .notoSansCJKkr(type: .medium, size: .medium)
		withTabButton.setTitleColor(.gray3, for: .normal)
		withTabButton.addTarget(self, action: #selector(withTabButtonDidTap), for: .touchUpInside)
		withTabButton.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setSharedTabButtonAttributes() {
		sharedTabButton.setTitle("공유", for: .normal)
		sharedTabButton.titleLabel?.font = .notoSansCJKkr(type: .medium, size: .medium)
		sharedTabButton.setTitleColor(.gray3, for: .normal)
		sharedTabButton.addTarget(self, action: #selector(sharedTabButtonDidTap), for: .touchUpInside)
		sharedTabButton.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setViewHierarchies() {
		addSubview(privateTabButton)
		addSubview(withTabButton)
		addSubview(sharedTabButton)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			privateTabButton.topAnchor.constraint(equalTo: topAnchor),
			privateTabButton.leadingAnchor.constraint(equalTo: leadingAnchor),
			privateTabButton.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			withTabButton.topAnchor.constraint(equalTo: topAnchor),
			withTabButton.leadingAnchor.constraint(equalTo: privateTabButton.trailingAnchor, constant: 24),
			withTabButton.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			sharedTabButton.topAnchor.constraint(equalTo: topAnchor),
			sharedTabButton.leadingAnchor.constraint(equalTo: withTabButton.trailingAnchor, constant: 24),
			sharedTabButton.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	@objc func privateTabButtonDidTap(_ sender: UIButton) {
		selectedTab = .privateTab
		delegate?.checkListTopTabView(self, tabDidSelect: .privateTab)
	}
	
	@objc func withTabButtonDidTap(_ sender: UIButton) {
		selectedTab = .withTab
		delegate?.checkListTopTabView(self, tabDidSelect: .withTab)
	}
	
	@objc func sharedTabButtonDidTap(_ sender: UIButton) {
		selectedTab = .sharedTab
		delegate?.checkListTopTabView(self, tabDidSelect: .sharedTab)
	}
	
	func updateTabButtonColor() {
		switch selectedTab {
		case .privateTab:
			privateTabButton.setTitleColor(.primary1, for: .normal)
			withTabButton.setTitleColor(.gray3, for: .normal)
			sharedTabButton.setTitleColor(.gray3, for: .normal)
			
		case .withTab:
			privateTabButton.setTitleColor(.gray3, for: .normal)
			withTabButton.setTitleColor(.primary1, for: .normal)
			sharedTabButton.setTitleColor(.gray3, for: .normal)
			
		case .sharedTab:
			privateTabButton.setTitleColor(.gray3, for: .normal)
			withTabButton.setTitleColor(.gray3, for: .normal)
			sharedTabButton.setTitleColor(.primary1, for: .normal)
		}
	}
}
