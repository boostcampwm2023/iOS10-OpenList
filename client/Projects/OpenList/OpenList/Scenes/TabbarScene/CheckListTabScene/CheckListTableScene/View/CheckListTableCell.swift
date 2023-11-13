//
//  CheckListTableCell.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import UIKit

final class CheckListTableCell: UICollectionViewCell {
	private let backView: UIView = .init()
	private let titleLabel: UILabel = .init()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupConfigure()
		setupLayout()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func configure(item: CheckListTableItem) {
		titleLabel.text = item.title
	}
}

private extension CheckListTableCell {
	func setupConfigure() {
		backView.backgroundColor = .white
		backView.layer.masksToBounds = true
		backView.layer.cornerRadius = 10
		
		layer.masksToBounds = false
		layer.shadowColor = UIColor(red: 177/255, green: 170/255, blue: 236/255, alpha: 1.0).cgColor
		layer.shadowOpacity = 0.3
		layer.shadowOffset = CGSize(width: 0, height: 3)
		layer.shadowRadius = 6
		
		titleLabel.textColor = .black
		titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
	}
	
	func setupLayout() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		backView.addSubview(titleLabel)
		
		backView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backView)
		
		NSLayoutConstraint.activate([
			backView.heightAnchor.constraint(equalToConstant: 48),
			backView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
			backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
			backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			
			titleLabel.centerYAnchor.constraint(equalTo: backView.centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 10),
			titleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -10),
		])
	}
}
