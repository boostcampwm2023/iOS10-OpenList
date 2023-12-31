//
//  DetailCheckListViewController.swift
//  OpenList
//
//  Created by 김영균 on 11/15/23.
//

import Combine
import UIKit

protocol PrivateDetailCheckListRoutingLogic: AnyObject {
	func dismissDetailScene()
}

final class PrivateDetailCheckListViewController: UIViewController, ViewControllable {
	enum LayoutConstant {
		static let checkListItemHeight: CGFloat = 44
		static let headerHeight: CGFloat = 24
		static let topPadding: CGFloat = 16
		static let horizontalPadding: CGFloat = 20
		static let spacingBetweenTitleAndCheckList: CGFloat = 32
	}
	
	// MARK: - Properties
	private let router: PrivateDetailCheckListRoutingLogic
	private let viewModel: any PrivateDetailCheckListViewModelable & PrivateDetailCheckListDataSource
	private var cancellables: Set<AnyCancellable> = []
	private var dataSource: PrivateDetailCheckListDiffableDataSource?
	private let navigationBar = OpenListNavigationBar(isBackButtonHidden: false, rightItems: [.more])
	
	// View Properties
	private let checkListView: UITableView = .init()
	private let headerView: CheckListHeaderView = .init()
	private let moreButton: UIButton = .init()
	
	// Event Properties
	private var viewWillAppear: PassthroughSubject<Void, Never> = .init()
	private let transformWith: PassthroughSubject<Void, Never> = .init()
	private let append: PassthroughSubject<CheckListItem, Never> = .init()
	private let update: PassthroughSubject<CheckListItem, Never> = .init()
	private let remove: PassthroughSubject<CheckListItem, Never> = .init() // 체크리스트 아이템을 삭제하는 이벤트
	private let removeCheckList: PassthroughSubject<Void, Never> = .init() //  체크리스트를 삭제하는 이벤트
	
	// MARK: - Initializers
	init(
		router: PrivateDetailCheckListRoutingLogic,
		viewModel: some PrivateDetailCheckListViewModelable & PrivateDetailCheckListDataSource
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewWillAppear.send(())
	}
}

// MARK: - Bind Methods
extension PrivateDetailCheckListViewController: ViewBindable {
	typealias State = PrivateDetailCheckListState
	typealias OutputError = Error
	
	func bind() {
		let input = PrivateDetailCheckListInput(
			viewWillAppear: viewWillAppear,
			append: append,
			update: update,
			remove: remove,
			transformWith: transformWith,
			removeCheckList: removeCheckList
		)
		let output = viewModel.transform(input)
		
		output
			.receive(on: DispatchQueue.main)
			.withUnretained(self)
			.sink { (owner, output) in owner.render(output) }
			.store(in: &cancellables)
	}
	
	func render(_ state: State) {
		switch state {
		case let .error(error):
			handleError(error)
		case let .viewLoad(checkList):
			viewLoad(checkList)
		case let .updateItem(item):
			updateItem(item)
		case .dismiss:
			router.dismissDetailScene()
		}
	}
	
	func handleError(_ error: OutputError) {
		dump(error)
	}
}

// MARK: - Helper
private extension PrivateDetailCheckListViewController {
	@IBAction func showMenu() {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let inviteAction = UIAlertAction(title: "함께 작성하기", style: .default) { [weak self] _ in
			self?.transformWith.send()
		}
		
		let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
			self?.removeCheckList.send()
		}
		
		let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
			print("didPress cancel")
		}
		
		actionSheet.addAction(inviteAction)
		actionSheet.addAction(deleteAction)
		actionSheet.addAction(cancelAction)
		
		self.present(actionSheet, animated: true, completion: nil)
	}
	
	func viewLoad(_ checkList: CheckList) {
		headerView.configure(title: checkList.title, isLocked: true)
		guard let items = checkList.items as? [CheckListItem] else { return }
		dataSource?.updateCheckList(items)
	}
	
	func updateItem(_ item: CheckListItem) {
		if item.title.isEmpty {
			dataSource?.deleteCheckListItem(item)
		} else {
			dataSource?.updateCheckListItem(item)
		}
	}
}

// MARK: - View Methods
private extension PrivateDetailCheckListViewController {
	func setViewAttributes() {
		view.backgroundColor = .background
		
		setNavigationAttributes()
		setCheckListViewAttributes()
		setHeaderViewAttributes()
	}
	
	func setNavigationAttributes() {
		navigationBar.delegate = self
	}
	
	func setCheckListViewAttributes() {
		checkListView.keyboardDismissMode = .interactive
		checkListView.translatesAutoresizingMaskIntoConstraints = false
		checkListView.registerCell(LocalCheckListItem.self)
		checkListView.registerCell(CheckListItemPlaceholder.self)
		checkListView.delegate = self
		checkListView.allowsSelection = false
		checkListView.separatorStyle = .none
		checkListView.backgroundColor = .background

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
		view.addSubview(navigationBar)
	}
	
	func setViewConstraints() {
		NSLayoutConstraint.activate([
			headerView.topAnchor.constraint(
				equalTo: navigationBar.bottomAnchor,
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
		dataSource = PrivateDetailCheckListDiffableDataSource(
			tableView: checkListView,
			cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
				switch itemIdentifier {
				case is CheckListItem:
					let cell = tableView.dequeueCell(LocalCheckListItem.self, for: indexPath)
					guard let item = itemIdentifier as? CheckListItem else { return cell }
					cell.configure(with: item, indexPath: indexPath)
					cell.delegate = self
					return cell
					
				case is PrivateCheckListPlaceholderItem:
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
extension PrivateDetailCheckListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func tableView(
		_ tableView: UITableView,
		trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
	) -> UISwipeActionsConfiguration? {
		switch indexPath.section {
		case 0:
			let configuration = UISwipeActionsConfiguration(actions: [deleteSwipeAction(at: indexPath)])
			configuration.performsFirstActionWithFullSwipe = false
			return configuration
			
		default:
			return nil
		}
	}
	
	func deleteSwipeAction(at indexPath: IndexPath) -> UIContextualAction {
		let item = checkListView.cellForRow(LocalCheckListItem.self, at: indexPath)
		let itemId = item.id
		let isChecked = item.isChecked
		let action = UIContextualAction(style: .destructive, title: "") { [weak self] _, _, completion in
			let checkListItem = CheckListItem(
				itemId: itemId,
				title: "",
				isChecked: isChecked
			)
			self?.remove.send(checkListItem)
			completion(true)
		}
		action.image = UIImage(systemName: "trash")
		action.backgroundColor = .red
		return action
	}
}

// MARK: - LocalCheckListItemDelegate
extension PrivateDetailCheckListViewController: LocalCheckListItemDelegate {
	func textViewDidEndEditing(
		_ textView: OpenListTextView,
		cell: LocalCheckListItem,
		indexPath: IndexPath
	) {
		let checkListItem = CheckListItem(
			itemId: cell.id,
			title: textView.text ?? "",
			isChecked: cell.isChecked
		)
		if let text = textView.text, !text.isEmpty {
			update.send(checkListItem)
		} else {
			remove.send(checkListItem)
		}
	}
	
	func textView(
		_ textView: OpenListTextView,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool {
		guard let text = textView.text else { return true }
		guard let stringRange = Range(range, in: text) else { return false }
		let updatedText = text.replacingCharacters(in: stringRange, with: string)
		return updatedText.count <= 30
	}
	
	func didChangedCheckButton(
		_ textView: OpenListTextView,
		cell: LocalCheckListItem,
		indexPath: IndexPath,
		isChecked: Bool
	) {
		let checkListItem = CheckListItem(
			itemId: cell.id,
			title: textView.text ?? "",
			isChecked: cell.isChecked
		)
		update.send(checkListItem)
	}
	
	func textViewDidChange(_ textView: OpenListTextView) {
		checkListView.beginUpdates()
		checkListView.endUpdates()
	}
}

// MARK: - CheckListItemPlaceholderDelegate
extension PrivateDetailCheckListViewController: CheckListItemPlaceholderDelegate {
	// 플레이스 홀더의 텍스트를 체크리스트에 추가합니다.
	func textViewDidEndEditing(_ textView: OpenListTextView, indexPath: IndexPath) {
		guard let text = textView.text else { return }
		let checkListItem = CheckListItem(
			itemId: UUID(),
			title: text,
			isChecked: false
		)
		
		append.send(checkListItem)
		dataSource?.updatePlaceholder()
	}
}

extension PrivateDetailCheckListViewController: OpenListNavigationBarDelegate {
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBackButton button: UIButton) {
		router.dismissDetailScene()
	}
	
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBarItem item: OpenListNavigationBarItem) {
		showMenu()
	}
}
