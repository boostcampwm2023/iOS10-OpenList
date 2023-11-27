//
//  OpenListNavigationItem.swift
//  OpenList
//
//  Created by 김영균 on 11/24/23.
//

import UIKit

enum OpenListNavigationItemType {
	case bell
	case search
	case more
	case logo(_ image: UIImage)
}

extension OpenListNavigationItemType {
	var image: UIImage {
		switch self {
		case .bell:
			return .bell.withRenderingMode(.alwaysTemplate)
		case .search:
			return .search.withRenderingMode(.alwaysTemplate)
		case .more:
			return .more.withRenderingMode(.alwaysTemplate)
		case .logo(let image):
			return image.withRenderingMode(.alwaysOriginal)
		}
	}
}

final class OpenListNavigationBarItem: UIButton {
	internal private(set) var type: OpenListNavigationItemType
	
	init(type: OpenListNavigationItemType) {
		self.type = type
		super.init(frame: .zero)
		setImage(type.image, for: .normal)
		imageView?.tintColor = .primary1
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

final class OpenListNavigationBackButtonItem: UIButton {
	init(backButtonTitle: String?) {
		super.init(frame: .zero)
		setImage(.chevronLeft.withRenderingMode(.alwaysTemplate), for: .normal)
		imageView?.tintColor = .primary1
		let attributedTitle = NSAttributedString(
			string: backButtonTitle ?? "",
			attributes: [
				.font: UIFont.notoSansCJKkr(type: .medium, size: .medium) as Any,
				.foregroundColor: UIColor.primary1
			]
		)
		setTitle(backButtonTitle, for: .normal)
		setTitleColor(.primary1, for: .normal)
		setAttributedTitle(attributedTitle, for: .normal)
		configuration?.contentInsets = .zero
		configuration?.imagePadding = -8
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setBackButtonTitle(_ title: String) {
		setTitle(title, for: .normal)
	}
}
