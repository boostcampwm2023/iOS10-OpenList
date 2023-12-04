//
//  AddCheckListItemButton.swift
//  OpenList
//
//  Created by wi_seong on 11/29/23.
//

import UIKit

final class AddCheckListItemButton: UIButton {
	private enum Image {
		static let disabled = UIImage.square.withTintColor(.gray3)
		static let checked = UIImage.plusSquare.withTintColor(.primary1)
		static let unchecked = UIImage.minusSquare.withTintColor(.primary1)
	}
	
	private enum State {
		case checked
		case unchecked
	}
	
	private var checkState: State = .unchecked {
		didSet {
			switch checkState {
			case .checked:
				setImage(Image.checked, for: .normal)
				
			case .unchecked:
				setImage(Image.unchecked, for: .normal)
			}
		}
	}
	
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		setViewAttributes()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension AddCheckListItemButton {
	func setViewAttributes() {
		backgroundColor = .background
		setImage(Image.disabled, for: .disabled)
		setImage(Image.unchecked, for: .normal)
	}
}

extension AddCheckListItemButton {
	var isChecked: Bool {
		return checkState == .checked
	}
	
	func setChecked() {
		checkState = .checked
		setImage(Image.checked, for: .normal)
		isEnabled = true
	}
	
	func setUnChecked() {
		checkState = .unchecked
		setImage(Image.unchecked, for: .normal)
		isEnabled = true
	}
	
	func setDeactivated() {
		setImage(Image.disabled, for: .normal)
		isEnabled = false
	}
	
	func toggleCheckState() {
		switch checkState {
		case .checked: setUnChecked()
		case .unchecked: setChecked()
		}
	}
}
