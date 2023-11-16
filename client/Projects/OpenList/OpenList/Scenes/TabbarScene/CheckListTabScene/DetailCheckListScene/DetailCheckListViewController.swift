//
//  DetailCheckListViewController.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Combine
import UIKit

protocol DetailCheckListRoutingLogic: AnyObject {}

final class DetailCheckListViewController: UIViewController, ViewControllable {
	enum LayoutConstant {
		static let checkListItemHeight: CGFloat = 44
		static let headerHeight: CGFloat = 24
		static let topPadding: CGFloat = 16
		static let horizontalPadding: CGFloat = 20
		static let spacingBetweenTitleAndCheckList: CGFloat = 32
	}
	
	// MARK: - Properties
	private let router: DetailCheckListRoutingLogic
	private let viewModel: any DetailCheckListViewModelable
	private var cancellables: Set<AnyCancellable> = []
	private var dataSource: DetailCheckListDiffableDataSource?
	
	// View Properties
	private let checkListView: UITableView = .init()
	private let headerView: CheckListHeaderView = .init()
	
	// MARK: - Initializers
	init(
		router: DetailCheckListRoutingLogic,
		viewModel: some DetailCheckListViewModelable
	) {
		self.router = router
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		view.endEditing(true)
	}
	
	// MARK: - View Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()
		makeDataSource()
		setViewAttributes()
		setViewHierarchies()
		setViewConstraints()
		bind()
	}
}

// MARK: - Bind Methods
extension DetailCheckListViewController: ViewBindable {
	typealias State = DetailCheckListState
	typealias OutputError = Error
	
	func bind() {}
	
	func render(_ state: State) {}
	
	func handleError(_ error: OutputError) {}
}

// MARK: - View Methods
private extension DetailCheckListViewController {
	func setViewAttributes() {
		view.backgroundColor = UIColor.background
		setCheckListViewAttributes()
		setHeaderViewAttributes()
	}
	
	func setCheckListViewAttributes() {
		checkListView.keyboardDismissMode = .interactive
		checkListView.translatesAutoresizingMaskIntoConstraints = false
		checkListView.registerCell(LocalCheckListItem.self)
		checkListView.registerCell(CheckListItemPlaceholder.self)
		checkListView.dataSource = dataSource
		checkListView.delegate = self
		checkListView.allowsSelection = false
		checkListView.separatorStyle = .none
		/// 테이블 뷰 영역 터치 시 키보드를 내린다.
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		tapGesture.cancelsTouchesInView = true
		checkListView.addGestureRecognizer(tapGesture)
	}
	
	func setHeaderViewAttributes() {
		headerView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func setViewHierarchies() {
		view.addSubview(checkListView)
		view.addSubview(headerView)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			headerView.topAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.topAnchor,
				constant: LayoutConstant.topPadding
			),
			headerView.leadingAnchor.constraint(
				equalTo: view.leadingAnchor,
				constant: LayoutConstant.horizontalPadding
			),
			headerView.trailingAnchor.constraint(
				lessThanOrEqualTo: view.trailingAnchor,
				constant: -LayoutConstant.horizontalPadding
			),
			checkListView.topAnchor.constraint(
				equalTo: headerView.bottomAnchor,
				constant: LayoutConstant.spacingBetweenTitleAndCheckList
			),
			checkListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			checkListView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
			checkListView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}
	
	@objc func hideKeyboard() {
		checkListView.endEditing(true)
	}
	
	func makeDataSource() {
		dataSource = DetailCheckListDiffableDataSource(
			tableView: checkListView,
			cellProvider: { tableView, indexPath, itemIdentifier in
				switch itemIdentifier {
				case is CheckListItem:
					let cell = tableView.dequeueCell(LocalCheckListItem.self, for: indexPath)
					guard let item = itemIdentifier as? CheckListItem else { return cell }
					cell.configure(with: item, indexPath: indexPath)
					cell.delegate = self
					return cell
					
				case is CheckListPlaceholderItem:
					let cell = tableView.dequeueCell(CheckListItemPlaceholder.self, for: indexPath)
					cell.configure(indexPath: indexPath)
					cell.delegate = self
					return cell
					
				default:
					return nil
				}
			}
		)
	}
}

// MARK: - UITableViewDelegate
extension DetailCheckListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return LayoutConstant.checkListItemHeight
	}
}

// MARK: - LocalCheckListItemDelegate
extension DetailCheckListViewController: LocalCheckListItemDelegate {
	func textFieldDidEndEditing(
		_ textField: CheckListItemTextField,
		cell: LocalCheckListItem,
		indexPath: IndexPath
	) {
		guard let text = textField.text else { return }
		// 로컬에 저장합니다.
		debugPrint(text)
	}
}

// MARK: - CheckListItemPlaceholderDelegate
extension DetailCheckListViewController: CheckListItemPlaceholderDelegate {
	// 플레이스 홀더의 텍스트를 체크리스트에 추가합니다.
	func textFieldDidEndEditing(_ textField: CheckListItemTextField, indexPath: IndexPath) {
		guard let text = textField.text else { return }
		textField.text = nil
		dataSource?.appendItems([CheckListItem(title: text, isChecked: false)], to: .checkList)
		dataSource?.updatePlaceholder()
	}
}
