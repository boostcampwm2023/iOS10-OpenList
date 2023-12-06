//
//  CustomAlertViewController.swift
//  OpenList
//
//  Created by wi_seong on 12/5/23.
//

import UIKit

final class CustomAlertViewController: UIViewController {
	var alertTitle: String?
	var placeholder: String?
	var textFieldText: String?
	var addActionConfirm: ConfirmAction?
	var addActionCancel: CancelAction?
	
	private var alertView: UIView = .init()
	private var titleLabel: UILabel = .init()
	private var horizontalDividerView: UIView = .init()
	private var buttonStackView: UIStackView = .init()
	private var confirmButton: UIButton = .init()
	private var cancelButton: UIButton = .init()
	private var textField: UITextField = .init()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let border = CALayer()
		border.frame = CGRect(x: 0, y: textField.frame.size.height + 4, width: textField.frame.width, height: 0.5)
		border.backgroundColor = UIColor.black.cgColor
		textField.layer.addSublayer(border)
	}
	
	@objc func confirm() {
		guard let text = textField.text else { return }
		addActionConfirm?.action?(text)
		dismiss(animated: true)
	}
	
	@objc func cancel() {
		addActionCancel?.action?()
		dismiss(animated: true)
	}
}

private extension CustomAlertViewController {
	func setViewAttributes() {
		view.backgroundColor = .gray2.withAlphaComponent(0.5)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cancel))
		view.addGestureRecognizer(tapGesture)
		
		setAlertViewAttributes()
		setTitleLabelAttributes()
		setTextFieldAttributes()
		setHorizontalDividerViewAttributes()
		setButtonStackViewAttributes()
		setConfirmButtonAttributes()
		setCancelButtonAttributes()
	}
	
	func setAlertViewAttributes() {
		alertView.translatesAutoresizingMaskIntoConstraints = false
		alertView.clipsToBounds = true
		alertView.layer.cornerRadius = 16
		alertView.backgroundColor = .background
	}
		
	func setTitleLabelAttributes() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.font = .notoSansCJKkr(type: .medium, size: .medium)
		titleLabel.textColor = .primary1
		titleLabel.textAlignment = .center
		titleLabel.text = alertTitle
		titleLabel.textAlignment = .left
	}
		
	func setTextFieldAttributes() {
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.placeholder = placeholder
		textField.font = .notoSansCJKkr(type: .regular, size: .small)
		textField.text = textFieldText
		textField.becomeFirstResponder()
	}
		
	func setHorizontalDividerViewAttributes() {
		horizontalDividerView.translatesAutoresizingMaskIntoConstraints = false
		horizontalDividerView.backgroundColor = .lightGray
	}
	
	func setButtonStackViewAttributes() {
		buttonStackView.translatesAutoresizingMaskIntoConstraints = false
		buttonStackView.distribution = .fillEqually
	}
		
	func setConfirmButtonAttributes() {
		confirmButton.translatesAutoresizingMaskIntoConstraints = false
		confirmButton.clipsToBounds = true
		confirmButton.setTitleColor(.white, for: .normal)
		confirmButton.titleLabel?.font = .notoSansCJKkr(type: .medium, size: .medium)
		confirmButton.backgroundColor = .gray3
		confirmButton.setTitle(addActionConfirm?.text, for: .normal)
		confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
	}
	
	func setCancelButtonAttributes() {
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.setTitleColor(.gray1, for: .normal)
		cancelButton.titleLabel?.font = .notoSansCJKkr(type: .medium, size: .medium)
		cancelButton.setTitle(addActionCancel?.text, for: .normal)
		cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
	}
	
	func setViewHierarchies() {
		view.addSubview(alertView)
		alertView.addSubview(titleLabel)
		alertView.addSubview(textField)
		alertView.addSubview(horizontalDividerView)
		alertView.addSubview(buttonStackView)
		buttonStackView.addArrangedSubview(confirmButton)
		buttonStackView.addArrangedSubview(cancelButton)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			alertView.widthAnchor.constraint(equalToConstant: 300),
			alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			alertView.bottomAnchor.constraint(
				equalTo: view.keyboardLayoutGuide.topAnchor,
				constant: -120
			),
			
			titleLabel.widthAnchor.constraint(equalToConstant: 260),
			titleLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
			titleLabel.topAnchor.constraint(
				equalTo: alertView.topAnchor,
				constant: 30
			),
			
			textField.widthAnchor.constraint(equalToConstant: 260),
			textField.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
			textField.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: 20
			),
			
			horizontalDividerView.widthAnchor.constraint(equalTo: alertView.widthAnchor),
			horizontalDividerView.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
			horizontalDividerView.heightAnchor.constraint(equalToConstant: 0.5),
			horizontalDividerView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 30),
			
			buttonStackView.widthAnchor.constraint(equalTo: alertView.widthAnchor),
			buttonStackView.heightAnchor.constraint(equalToConstant: 50),
			buttonStackView.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
			buttonStackView.topAnchor.constraint(equalTo: horizontalDividerView.bottomAnchor),
			buttonStackView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor)
		])
	}
}
