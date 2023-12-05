//
//  RecommendCheckListCell.swift
//  OpenList
//
//  Created by 김영균 on 12/4/23.
//

import UIKit

final class RecommendCheckListCell: UICollectionViewCell {
	enum Section { case checkList4Row }
	typealias CheckList4RowDataSource = UICollectionViewDiffableDataSource<Section, [CheckListItem]>
	typealias CheckList4RowSnapShot = NSDiffableDataSourceSnapshot<Section, [CheckListItem]>
	
	// MARK: - Properties
	private let imageView: UIImageView = .init()
	private let titleLabel: UILabel = .init()
	private let dateLabel: UILabel = .init()
	private let checkListView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())
	private var checkList4RowDataSource: CheckList4RowDataSource?
	private let checkListPageControl: UIPageControl = .init()
	
	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure(with item: CheckList) {
		titleLabel.text = item.title
		dateLabel.text = item.createdAt.toString()
		let chunkedCheckListItems = item.items.chunk(by: 4)
		checkListPageControl.numberOfPages = chunkedCheckListItems.count
		updatePageControl(with: 0)
		updateSection(with: chunkedCheckListItems)
	}
}

private extension RecommendCheckListCell {
	enum LayoutConstant {
		static let imageSize: CGSize = .init(width: 100, height: 100)
		static let horizontalSpacing: CGFloat = 20
		static let titleLabelHorizontalSpacing: CGFloat = 10
		static let dateLabelTopSpacing: CGFloat = 4
		static let dateLabelHorizontalSpacing: CGFloat = 10
		static let checkList4RowViewTopSpacing: CGFloat = 14
		static let pageControlTopSpacing: CGFloat = 20
	}
	
	func setViewAttributes() {
		setImageViewAttributes()
		setTitleLabelAttributes()
		setDateLabelAttributes()
		setCheckListViewAttributes()
		setCheckListPageControlAttributes()
	}
	
	func setViewHierarchies() {
		contentView.addSubview(imageView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(dateLabel)
		contentView.addSubview(checkListView)
		contentView.addSubview(checkListPageControl)
	}
	
	func setViewConstraints() {
		setImageViewConstraints()
		setTitleLabelConstraints()
		setDateLabelConstraints()
		setCheckList4RowViewConstraints()
		setCheckListPageControlConstraints()
	}
}

private extension RecommendCheckListCell {
	func setImageViewAttributes() {
		imageView.backgroundColor = .red
		imageView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setTitleLabelAttributes() {
		titleLabel.textColor = .label
		titleLabel.font = UIFont.notoSansCJKkr(type: .medium, size: .medium)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setDateLabelAttributes() {
		dateLabel.textColor = .gray3
		dateLabel.font = UIFont.notoSansCJKkr(type: .regular, size: .small)
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setCheckListViewAttributes() {
		checkListView.backgroundColor = .background
		checkListView.registerCell(RecommendCheckList4ItemCell.self)
		checkListView.collectionViewLayout = makeCheckListViewLayout()
		checkList4RowDataSource = .init(collectionView: checkListView) { collectionView, indexPath, item in
			let cell = collectionView.dequeueCell(RecommendCheckList4ItemCell.self, for: indexPath)
			cell.configure(with: item)
			return cell
		}
		checkListView.showsHorizontalScrollIndicator = false
		checkListView.showsVerticalScrollIndicator = false
		makeSection()
		checkListView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setCheckListPageControlAttributes() {
		checkListPageControl.isUserInteractionEnabled = false
		checkListPageControl.translatesAutoresizingMaskIntoConstraints = false
		checkListPageControl.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
	}
	
	func updatePageControl(with page: Int) {
		checkListPageControl.currentPage = page
		let circleFillImage = UIImage(systemName: "circle.fill")?.withTintColor(.primary1, renderingMode: .alwaysOriginal)
		let circleImage = UIImage(systemName: "circle")?.withTintColor(.primary1, renderingMode: .alwaysOriginal)
		
		for index in 0..<checkListPageControl.numberOfPages {
			if index == page {
				checkListPageControl.setCurrentPageIndicatorImage(circleFillImage, forPage: index)
			} else {
				checkListPageControl.setIndicatorImage(circleImage, forPage: index)
			}
		}
	}
	
	func setImageViewConstraints() {
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			imageView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: LayoutConstant.horizontalSpacing
			),
			imageView.widthAnchor.constraint(equalToConstant: LayoutConstant.imageSize.width),
			imageView.heightAnchor.constraint(equalToConstant: LayoutConstant.imageSize.height)
		])
	}
	
	func setTitleLabelConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
			titleLabel.leadingAnchor.constraint(
				equalTo: imageView.trailingAnchor,
				constant: LayoutConstant.titleLabelHorizontalSpacing
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -LayoutConstant.horizontalSpacing
			)
		])
	}
	
	func setDateLabelConstraints() {
		NSLayoutConstraint.activate([
			dateLabel.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: LayoutConstant.dateLabelTopSpacing
			),
			dateLabel.leadingAnchor.constraint(
				equalTo: imageView.trailingAnchor,
				constant: LayoutConstant.titleLabelHorizontalSpacing
			),
			dateLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -LayoutConstant.horizontalSpacing
			)
		])
	}
	
	func setCheckList4RowViewConstraints() {
		NSLayoutConstraint.activate([
			checkListView.topAnchor.constraint(
				equalTo: imageView.bottomAnchor,
				constant: LayoutConstant.checkList4RowViewTopSpacing
			),
			checkListView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			checkListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			checkListView.heightAnchor.constraint(equalToConstant: 110)
		])
	}
	
	func setCheckListPageControlConstraints() {
		NSLayoutConstraint.activate([
			checkListPageControl.topAnchor.constraint(
				equalTo: checkListView.bottomAnchor,
				constant: LayoutConstant.pageControlTopSpacing
			),
			checkListPageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			checkListPageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		])
	}
}

private extension RecommendCheckListCell {
	func makeCheckListViewLayout() -> UICollectionViewLayout {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1),
			heightDimension: .estimated(110)
		)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(0.9),
			heightDimension: .estimated(110)
		)
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
		
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .groupPaging
		section.visibleItemsInvalidationHandler = { [weak self] _, offset, environment in
			guard let self else { return }
			let numberOfPages = self.checkListPageControl.numberOfPages
			let currentIndex = min(numberOfPages, Int(round(offset.x / environment.container.contentSize.width)))
			self.updatePageControl(with: currentIndex)
		}
		section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
		return UICollectionViewCompositionalLayout(section: section)
	}
	
	func makeSection() {
		guard let checkList4RowDataSource else { return }
		var snapShot = CheckList4RowSnapShot()
		snapShot.appendSections([.checkList4Row])
		checkList4RowDataSource.apply(snapShot)
	}
	
	func updateSection(with items: [[CheckListItem]]) {
		guard let checkList4RowDataSource else { return }
		var snapShot = checkList4RowDataSource.snapshot()
		snapShot.appendItems(items, toSection: .checkList4Row)
		checkList4RowDataSource.apply(snapShot)
	}
}

fileprivate extension Collection {
	// 주어진 배열을 size개씩 묶어서 반환하는 메서드
	func chunk(by size: Int) -> [[Element]] {
		return stride(from: 0, to: count, by: size).map { offset in
			let start = index(startIndex, offsetBy: offset)
			let end = index(start, offsetBy: size)
			return Array(self[start ..< Swift.min(end, endIndex)])
		}
	}
}

fileprivate extension Date {
	func toString() -> String {
		let calendar = Calendar.current
		let currentDate = Date()
		
		if calendar.isDateInToday(self) {
			return "오늘"
		} else if calendar.isDateInYesterday(self) {
			return "어제"
		}
		
		let components = calendar.dateComponents([.year, .month, .weekOfYear, .day], from: self, to: currentDate)
		
		if let years = components.year, years > 0 {
			return "\(years)년 전"
		} else if let months = components.month, months > 0 {
			return "\(months)달 전"
		} else if let weeks = components.weekOfYear, weeks > 0 {
			return "\(weeks)주 전"
		} else if let days = components.day, days > 0 {
			return "\(days)일 전"
		}
		
		return "이전"
	}
}
