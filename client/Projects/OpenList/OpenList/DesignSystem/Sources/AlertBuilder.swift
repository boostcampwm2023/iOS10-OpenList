//
//  AlertBuilder.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import UIKit

final class AlertBuilder {
	private let baseViewController: UIViewController
	private let alertViewController = CustomAlertViewController()
	
	private var alertTitle: String?
	private var placeholder: String?
	private var textFieldText: String?
	private var addActionConfirm: ConfirmAction?
	private var addActionCancel: CancelAction?
	
	init(viewController: UIViewController) {
		baseViewController = viewController
	}
}

extension AlertBuilder {
	func setTitle(_ text: String) -> AlertBuilder {
		alertTitle = text
		return self
	}
	
	func setPlaceholder(_ text: String) -> AlertBuilder {
		placeholder = text
		return self
	}
	
	func setTextFieldText(_ text: String) -> AlertBuilder {
		textFieldText = text
		return self
	}
	
	func addActionConfirm(_ text: String, action: ((String) -> Void)? = nil) -> AlertBuilder {
		addActionConfirm = ConfirmAction(text: text, action: action)
		return self
	}
	
	func addActionCancel(_ text: String, action: (() -> Void)? = nil) -> AlertBuilder {
		addActionCancel = CancelAction(text: text, action: action)
		return self
	}
	
	@discardableResult
	func show() -> Self {
		alertViewController.modalPresentationStyle = .overFullScreen
		alertViewController.modalTransitionStyle = .crossDissolve
		
		alertViewController.alertTitle = alertTitle
		alertViewController.textFieldText = textFieldText
		alertViewController.placeholder = placeholder
		alertViewController.addActionConfirm = addActionConfirm
		alertViewController.addActionCancel = addActionCancel
		
		baseViewController.present(alertViewController, animated: true)
		return self
	}
}

struct ConfirmAction {
	var text: String?
	var action: ((String) -> Void)?
}

struct CancelAction {
	var text: String?
	var action: (() -> Void)?
}
