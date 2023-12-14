//
//  RecommendCheckListCell.swift
//  OpenList
//
//  Created by 김영균 on 12/4/23.
//

import UIKit

final class RecommendCheckListCell: UICollectionViewCell {
	enum Section { case checkListItem }
	typealias CheckListRowDataSource = UICollectionViewDiffableDataSource<Section, FeedCheckListItem>
	typealias CheckList4RowSnapShot = NSDiffableDataSourceSnapshot<Section, FeedCheckListItem>
	
	// MARK: - Properties
	private let imageView: UIView = .init() 	// 체크리스트의 이미지를 보여주는 뷰 (이미지 뷰와 레이어에 그림자가 담겨있다.)
	private var imageLayerView: UIImageView? 	// 이미지 뷰의 이미지를 보여주는 뷰
	private let titleLabel: UILabel = .init()
	private let dateLabel: UILabel = .init()
	private let checkListView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())
	private var checkListRowDataSource: CheckListRowDataSource?
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
	
	override func prepareForReuse() {
		super.prepareForReuse()
		checkListRowDataSource = nil
		checkListView.isUserInteractionEnabled = false
		checkListPageControl.isHidden = true
	}
	
	func configure(with item: FeedCheckList) {
		titleLabel.text = item.title
		dateLabel.text = item.createdAt.toDateString()?.toString()
		imageLayerView?.image = .logo
		let chunkedCheckListItems = item.items.chunk(by: 4)
		checkListPageControl.numberOfPages = chunkedCheckListItems.count
		
		if chunkedCheckListItems.count > 1 {
			// 체크리스트가 페이징이 가능하게한다.
			checkListView.isUserInteractionEnabled = true
			// 페이지 컨트롤을 보여준다.
			checkListPageControl.isHidden = false
			updatePageControl(with: 0)
		}
		
		checkListView.collectionViewLayout = makeCheckListViewLayout()
		checkListRowDataSource = makeDataSource()
		updateSection(with: item.items)
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
		imageView.translatesAutoresizingMaskIntoConstraints = false
		let imageLayerView = makeImageLayerView()
		self.imageLayerView = imageLayerView
		imageView.addSubview(imageLayerView)
		applyImageShadowLayer()
	}
		
	func setTitleLabelAttributes() {
		titleLabel.textColor = .gray1
		titleLabel.font = .notoSansCJKkr(type: .medium, size: .medium)
		titleLabel.numberOfLines = 0
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setDateLabelAttributes() {
		dateLabel.textColor = .gray3
		dateLabel.font = UIFont.notoSansCJKkr(type: .regular, size: .small)
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setCheckListViewAttributes() {
		checkListView.backgroundColor = .background
		checkListView.registerCell(RecommendCheckListItemCell.self)
		checkListView.showsHorizontalScrollIndicator = false
		checkListView.showsVerticalScrollIndicator = false
		checkListView.translatesAutoresizingMaskIntoConstraints = false
		checkListView.isUserInteractionEnabled = false
	}
	
	func setCheckListPageControlAttributes() {
		checkListPageControl.isHidden = true
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
			checkListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
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

// MARK: - Make Methods
private extension RecommendCheckListCell {
	func makeImageLayerView() -> UIImageView {
		let imageLayerView = UIImageView()
		imageView.addSubview(imageLayerView)
		imageLayerView.layer.masksToBounds = true
		imageLayerView.layer.cornerRadius = 10
		imageLayerView.translatesAutoresizingMaskIntoConstraints = false
		imageLayerView.topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
		imageLayerView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
		imageLayerView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
		imageLayerView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
		return imageLayerView
	}
	
	func applyImageShadowLayer() {
		imageView.layer.masksToBounds = false
		imageView.layer.cornerRadius = 10
		imageView.layer.shadowPath = UIBezierPath(
			roundedRect: .init(origin: .zero, size: LayoutConstant.imageSize),
			cornerRadius: 0
		).cgPath
		imageView.layer.shadowColor = UIColor.shadow1.cgColor
		imageView.layer.shadowOpacity = 1
		imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
		imageView.layer.shadowRadius = 6
	}
	
	func makeCheckListViewLayout() -> UICollectionViewLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(24))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(100))
		let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: 4)
		group.interItemSpacing = .fixed(10)
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
	
	func makeDataSource() -> CheckListRowDataSource {
		return CheckListRowDataSource(collectionView: checkListView) { collectionView, indexPath, item in
			let cell = collectionView.dequeueCell(RecommendCheckListItemCell.self, for: indexPath)
			cell.configure(with: item)
			return cell
		}
	}
	func updateSection(with items: [FeedCheckListItem]) {
		guard let checkListRowDataSource else { return }
		var snapShot = CheckList4RowSnapShot()
		snapShot.appendSections([.checkListItem])
		snapShot.appendItems(items, toSection: .checkListItem)
		checkListRowDataSource.apply(snapShot)
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

fileprivate extension String {
	func toDateString() -> Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		return dateFormatter.date(from: self)
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
