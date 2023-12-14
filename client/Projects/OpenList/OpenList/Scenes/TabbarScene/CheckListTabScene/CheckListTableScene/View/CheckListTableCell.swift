//
//  CheckListTableCell.swift
//  OpenList
//
//  Created by wi_seong on 11/13/23.
//

import UIKit

final class CheckListTableCell: UICollectionViewCell {
	private let cellContentInset: UIEdgeInsets = .init(top: 12, left: 20, bottom: 12, right: 20)
	private let backView: UIView = .init()
	private let titleLabel: UILabel = .init()
	private let achievementPercentLabel: UILabel = .init()
	private let gaugeView: GaugeView = .init()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setViewAttributes()
		setViewHierarchies()
		setConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func configure(item: CheckListTableItem) {
		titleLabel.text = item.title
		achievementPercentLabel.text = String(Int(item.achievementRate * 100)) + "%"
		gaugeView.configure(with: item.achievementRate)
	}
}

private extension CheckListTableCell {
	func setViewAttributes() {
		setLayerAttributes()
		setBackViewAttributes()
		setTitleLabelAttributes()
		setAchievementPercentLabelAttributes()
	}
	
	func setLayerAttributes() {
		layer.masksToBounds = false
		layer.shadowPath = UIBezierPath(
			roundedRect: .init(
				origin: .init(x: cellContentInset.left, y: cellContentInset.top),
				size: .init(
					width: frame.width - cellContentInset.left * 2,
					height: 48
				)
			),
			cornerRadius: backView.layer.cornerRadius
		).cgPath
		layer.shadowColor = UIColor.shadow1.cgColor
		layer.shadowOpacity = 0.3
		layer.shadowOffset = CGSize(width: 0, height: 3)
		layer.shadowRadius = 6
	}
	
	func setBackViewAttributes() {
		backView.backgroundColor = .background
		backView.layer.masksToBounds = true
		backView.layer.cornerRadius = 8
	}
	
	func setTitleLabelAttributes() {
		titleLabel.textColor = .gray1
		titleLabel.font = .notoSansCJKkr(type: .medium, size: .small)
		
		achievementPercentLabel.font = .notoSansCJKkr(type: .regular, size: .small)
		achievementPercentLabel.textColor = .primary1
	}
	
	func setAchievementPercentLabelAttributes() {
		achievementPercentLabel.font = .notoSansCJKkr(type: .regular, size: .small)
		achievementPercentLabel.textColor = .primary1
	}
	
	func setViewHierarchies() {
		[
			titleLabel,
			achievementPercentLabel,
			gaugeView
		].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			backView.addSubview($0)
		}
		
		backView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backView)
	}
	
	func setConstraints() {
		let contentInset: UIEdgeInsets = .init(top: 14, left: 10, bottom: 14, right: 10)
		
		NSLayoutConstraint.activate([
			backView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: cellContentInset.top),
			backView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -cellContentInset.bottom),
			backView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: cellContentInset.left),
			backView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -cellContentInset.right),
			
			titleLabel.topAnchor.constraint(equalTo: backView.topAnchor, constant: contentInset.top),
			titleLabel.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -contentInset.bottom),
			titleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: contentInset.left),
			titleLabel.trailingAnchor.constraint(equalTo: gaugeView.leadingAnchor, constant: 4),
			
			achievementPercentLabel.centerXAnchor.constraint(equalTo: gaugeView.centerXAnchor),
			
			gaugeView.widthAnchor.constraint(equalToConstant: 44),
			gaugeView.heightAnchor.constraint(equalToConstant: 4),
			gaugeView.topAnchor.constraint(equalTo: achievementPercentLabel.bottomAnchor, constant: 2),
			gaugeView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
			gaugeView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -contentInset.right)
		])
	}
}
