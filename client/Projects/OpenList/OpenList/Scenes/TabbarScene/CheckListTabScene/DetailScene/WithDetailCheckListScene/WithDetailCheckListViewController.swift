//
//  WithDetailCheckListViewController.swift
//  OpenList
//
//  Created by wi_seong on 11/23/23.
//

import Combine
import CustomSocket
import UIKit

protocol WithDetailCheckListRoutingLogic: AnyObject {
	func dismissDetailScene()
}

final class WithDetailCheckListViewController: UIViewController, ViewControllable {
	enum LayoutConstant {
		static let checkListItemHeight: CGFloat = 44
		static let headerHeight: CGFloat = 24
		static let topPadding: CGFloat = 16
		static let horizontalPadding: CGFloat = 20
		static let spacingBetweenTitleAndCheckList: CGFloat = 32
	}
	
	// MARK: - Properties
	private let router: WithDetailCheckListRoutingLogic
	private let viewModel: any WithDetailCheckListViewModelable & WithDetailCheckListDataSource
	private var cancellables: Set<AnyCancellable> = []
	private var dataSource: WithDetailCheckListDiffableDataSource?
	private var isOpenSocket: Bool = false
	private let navigationBar = OpenListNavigationBar(isBackButtonHidden: false, rightItems: [.more])
	private var userIndicatingDictionary: [String: IndexPath] = [:]
	
	// View Properties
	private let checkListView: UITableView = .init()
	private let headerView: CheckListHeaderView = .init()
	
	// Event Properties
	private let viewWillAppear: PassthroughSubject<Void, Never> = .init()
	private let socketConnet: PassthroughSubject<Void, Never> = .init()
	private let textShouldChange: PassthroughSubject<TextChange, Never> = .init()
	private let textDidChange: PassthroughSubject<WithCheckListItemChange, Never> = .init()
	private let appendDocument: PassthroughSubject<EditText, Never> = .init()
	private let removeDocument: PassthroughSubject<EditText, Never> = .init()
	private let receive: PassthroughSubject<String, Never> = .init()
	private let checklistDidToggle: PassthroughSubject<CheckToggle, Never> = .init()
	private let deleteCheckList: PassthroughSubject<Void, Never> = .init()
	
	// MARK: - Initializers
	init(
		router: WithDetailCheckListRoutingLogic,
		viewModel: some WithDetailCheckListViewModelable & WithDetailCheckListDataSource
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
		setWebSocket()
		bind()
		socketConnet.send()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewWillAppear.send(())
	}
	
	deinit {
		WebSocket.shared.closeWebSocket()
	}
}

// MARK: - Bind Methods
extension WithDetailCheckListViewController: ViewBindable {
	typealias State = WithDetailCheckListState
	typealias OutputError = Error
	
	func bind() {
		let input = WithDetailCheckListInput(
			viewWillAppear: viewWillAppear,
			socketConnet: socketConnet,
			textShouldChange: textShouldChange,
			textDidChange: textDidChange,
			appendDocument: appendDocument,
			removeDocument: removeDocument,
			receive: receive,
			checklistDidTap: checklistDidToggle,
			deleteCheckList: deleteCheckList
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
		case .none:
			break
		case let .viewWillAppear(checkList):
			viewAppear(checkList)
		case let .updateItems(items):
			updateTextField(to: items)
		case let .appendItem(item):
			appendItem(item)
		case let .removeItem(content):
			dump(content)
		case let .socketConnet(isConnect):
			dump(isConnect)
		case .checkToggle:
			break
		case .dismiss:
			router.dismissDetailScene()
		}
	}
	
	func handleError(_ error: OutputError) {}
}

// MARK: - Helper
private extension WithDetailCheckListViewController {
	@IBAction func showMenu() {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let inviteAction = UIAlertAction(title: "초대하기", style: .default) { [weak self] _ in
			self?.invite()
		}
		
		let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
			self?.deleteCheckList.send()
		}
		
		let cancelAction = UIAlertAction(title: "취소", style: .cancel)
		
		actionSheet.addAction(inviteAction)
		actionSheet.addAction(deleteAction)
		actionSheet.addAction(cancelAction)
		
		self.present(actionSheet, animated: true, completion: nil)
	}
	
	func invite() {
		var objectsToShare = [String]()
		let inviteLink = viewModel.inviteLinkUrlString
		objectsToShare.append(inviteLink)
		
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		activityVC.popoverPresentationController?.sourceView = self.view
		
		self.present(activityVC, animated: true, completion: nil)
	}
	
	func viewAppear(_ checkList: CheckList) {
		headerView.configure(title: checkList.title, isLocked: false)
		checkList.items.forEach { [weak self] in
			self?.dataSource?.receiveCheckListItem(with: $0)
		}
	}
	
	func updateTextField(to items: [any ListItem]) {
		items.forEach { [weak self] in
			self?.dataSource?.receiveCheckListItem(with: $0)
		}
	}
	
	func appendItem(_ item: any ListItem) {
		dataSource?.appendCheckListItem(item)
		dataSource?.updatePlaceholder()
	}
	
	func removeItem(id: UUID, indexPath: IndexPath) {
		removeDocument.send(
			.init(
				id: id,
				content: "",
				range: .init(location: 0, length: 0)
			)
		)
		dataSource?.deleteCheckListItem(at: indexPath)
	}
}

// MARK: - View Methods
private extension WithDetailCheckListViewController {
	func setViewAttributes() {
		view.backgroundColor = UIColor.background
		
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
		checkListView.registerCell(WithCheckListItemCell.self)
		checkListView.registerCell(CheckListItemPlaceholder.self)
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
	
	func setWebSocket() {
		do {
			WebSocket.shared.delegate = self
			WebSocket.shared.url = viewModel.webSocketUrl
			try WebSocket.shared.openWebSocket()
		} catch {
			dump(error)
		}
	}
	
	func webSocketReceive() {
		if !isOpenSocket {
			return
		}
		
		DispatchQueue.global().async {
			WebSocket.shared.receive { [weak self] jsonString, data in
				if let jsonString {
					self?.receive.send(jsonString)
					self?.webSocketReceive()
				} else if let data {
					guard let jsonString = String(data: data, encoding: .utf8) else { return }
					self?.receive.send(jsonString)
					self?.webSocketReceive()
				}
			}
		}
	}
	
	@objc func hideKeyboard() {
		checkListView.endEditing(true)
	}
	
	func makeDataSource() {
		dataSource = WithDetailCheckListDiffableDataSource(
			tableView: checkListView,
			cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
				switch itemIdentifier {
				case is WithCheckListItem:
					let cell = tableView.dequeueCell(WithCheckListItemCell.self, for: indexPath)
					guard let item = itemIdentifier as? WithCheckListItem else { return cell }
					let name = item.name ?? ""
					self?.handleNewData(name: name)
					self?.userIndicatingDictionary[name] = indexPath
					cell.configure(with: item, indexPath: indexPath)
					cell.delegate = self
					return cell
					
				case is WithCheckListPlaceholderItem:
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
	
	func handleNewData(name: String) {
		if let previousIndexpath = self.userIndicatingDictionary[name] {
			guard let cell = checkListView.cellForRow(at: previousIndexpath) as? WithCheckListItemCell else { return }
			cell.resetUserPosition()
		}
	}
}

// MARK: - UITableViewDelegate
extension WithDetailCheckListViewController: UITableViewDelegate {
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
		let item = checkListView.cellForRow(WithCheckListItemCell.self, at: indexPath)
		let action = UIContextualAction(style: .destructive, title: "") { [weak self] _, _, completion in
			let id = item.cellId ?? UUID()
			self?.removeItem(id: id, indexPath: indexPath)
			completion(true)
		}
		action.image = UIImage(systemName: "trash")
		action.backgroundColor = .red
		return action
	}
}

// MARK: - WithCheckListItemDelegate
extension WithDetailCheckListViewController: WithCheckListItemCellDelegate {
	func withCheckListTextViewDidChange(_ textView: OpenListTextView, indexPath: IndexPath) {
		let cell = checkListView.cellForRow(WithCheckListItemCell.self, at: indexPath)
		textDidChange.send(WithCheckListItemChange(text: textView.text, isChecked: cell.isChecked))
		checkListView.beginUpdates()
		checkListView.endUpdates()
	}
	
	func textViewDidEndEditing(
		_ textView: OpenListTextView,
		cell: WithCheckListItemCell,
		indexPath: IndexPath
	) {
		guard let text = textView.text, !text.isEmpty else {
			dataSource?.deleteCheckListItem(at: indexPath)
			return
		}
	}
	
	func textView(
		_ textView: OpenListTextView,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String,
		indexPath: IndexPath,
		cellId: UUID
	) -> Bool {
		guard let text = textView.text else { return true }
		guard let stringRange = Range(range, in: text) else { return false }
		let updatedText = text.replacingCharacters(in: stringRange, with: string)
		guard updatedText.count <= 30 && range.length < 2 else { return false }
		guard !updatedText.isEmpty else {
			removeItem(id: cellId, indexPath: indexPath)
			return false
		}
		textShouldChange.send(
			.init(id: cellId, range: range, oldString: text, replacementString: string)
		)
		return true
	}
	
	func checklistDidTap(_ indexPath: IndexPath, cellId: UUID, isChecked: Bool) {
		checklistDidToggle.send(CheckToggle(id: cellId, state: isChecked))
	}
}

extension WithDetailCheckListViewController: URLSessionWebSocketDelegate {
	func urlSession(
		_ session: URLSession,
		webSocketTask: URLSessionWebSocketTask,
		didOpenWithProtocol protocol: String?
	) {
		isOpenSocket = true
		webSocketReceive()
	}
	
	func urlSession(
		_ session: URLSession,
		webSocketTask: URLSessionWebSocketTask,
		didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
		reason: Data?
	) {
		isOpenSocket = false
	}
}

// MARK: - WithCheckListItemPlaceholderDelegate
extension WithDetailCheckListViewController: CheckListItemPlaceholderDelegate {
	func textViewDidChange(_ textView: OpenListTextView) {
		checkListView.beginUpdates()
		checkListView.endUpdates()
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
	
	// 플레이스 홀더의 텍스트를 체크리스트에 추가합니다.
	func textViewDidEndEditing(_ textView: OpenListTextView, indexPath: IndexPath) {
		guard let text = textView.text else { return }
		appendDocument.send(.init(content: text, range: .init(location: 0, length: text.count)))
	}
}

extension WithDetailCheckListViewController: OpenListNavigationBarDelegate {
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBackButton button: UIButton) {
		router.dismissDetailScene()
	}
	
	func openListNavigationBar(_ navigationBar: OpenListNavigationBar, didTapBarItem item: OpenListNavigationBarItem) {
		showMenu()
	}
}
