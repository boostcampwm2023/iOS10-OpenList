//
//  CheckListEmptyView.swift
//  OpenList
//
//  Created by 김영균 on 11/29/23.
//

import UIKit

final class CheckListEmptyView: UIView {
	private let checklistImageView: UIImageView = .init()
	private let descriptionLabel: UILabel = .init()
	private let subDescriptionLabel: UILabel = .init()
	private let checkListType: CheckListTabType
	
	init(checkListType: CheckListTabType) {
		self.checkListType = checkListType
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

private extension CheckListEmptyView {
	func setViewAttributes() {
		backgroundColor = .background
		checklistImageView.image = UIImage.checklistTab
			.resizeImage(size: .init(width: 48, height: 48))?
			.withRenderingMode(.alwaysTemplate)
		checklistImageView.tintColor = .primary1
		checklistImageView.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.text = checkListType.description
		descriptionLabel.font = .notoSansCJKkr(type: .medium, size: .large)
		descriptionLabel.textColor = .primary1
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		subDescriptionLabel.text = checkListType.subDescription
		subDescriptionLabel.font = .notoSansCJKkr(type: .regular, size: .small)
		subDescriptionLabel.textColor = .gray3
		subDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setViewHierarchies() {
		addSubview(checklistImageView)
		addSubview(descriptionLabel)
		addSubview(subDescriptionLabel)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			checklistImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			checklistImageView.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -20),
			
			descriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			descriptionLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			
			subDescriptionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
			subDescriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}
}

fileprivate extension CheckListTabType {
	var description: String {
		switch self {
		case .privateTab:
			return "아직 체크리스트가 없습니다!"
		case .withTab:
			return "아직 함께하는 체크리스트가 없습니다!"
		case .sharedTab:
			return "아직 공유된 체크리스트가 없습니다!"
		}
	}
	
	var subDescription: String {
		switch self {
		case .privateTab:
			return "나만의 체크리스트를 작성해주세요."
		case .withTab:
			return "함께 체크리스트를 작성해보세요."
		case .sharedTab:
			return "다른 사람들과 함께 공유하세요."
		}
	}
}
