//
//  ChatRoomViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import SnapKit

class ChatRoomViewController: UIViewController {

     // MARK: - UI Elements
    private lazy var emptyLabel: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.text = "You don't have any messages yet."
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 20)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        return emptyLabel
    }()

    private lazy var messagesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.cellIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var textInputView: TextEntryView = {
        let view = TextEntryView(frame: .zero, viewController: self)
        return view
    }()

    // Title View
    private lazy var titleView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    private lazy var titleViewRoomNameLabel : UILabel = {
        let label = UILabel()
        label.text = chatRoom?.name ?? ""
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    private lazy var titleViewMemberCountLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 10, weight: .medium)
        return label
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        return view
    }()

    private lazy var messageOptionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MessageOptionsTableViewCell.self, forCellReuseIdentifier: MessageOptionsTableViewCell.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 40
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 10
        return tableView
    }()


    // MARK: - Private Properties
    private var chatRoom: ChatRoom?
    private var navigationBarHeight: CGFloat = 0
    private var tabbarHeight: CGFloat = 0
    private var viewmodel: ChatRoomViewModel?
    private var isKeyboardOpen = false
    private var wasKeyboardOpen = false
    private var keyboardSize: CGRect?

    // MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(chatRoom: ChatRoom) {
        super.init(nibName: nil, bundle: nil)
        self.chatRoom = chatRoom
        self.viewmodel = ChatRoomViewModel(chatroom: chatRoom)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setup()
        layout()
        setTableViewDelegates()
        addObservers()
        fetchMessagesAndObserve()
    }

    override func viewDidLayoutSubviews() {
        navigationItem.backButtonTitle = "Back To Room"
        view.backgroundColor = .systemBackground
    }

    override func viewDidAppear(_ animated: Bool) {
        self.scrollToBottom()
        AppGlobal.shared.currentPage = .chatRoom
    }

    //MARK: - Setup
    private func setTableViewDelegates() {
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        textInputView.delegate = self
    }

    private func configureNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .systemPink

        addTitleView()

        // Bar Button Items
        let editRoomSettingsButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(editRoomSettings))
        navigationItem.rightBarButtonItems = [editRoomSettingsButton]
        navigationItem.rightBarButtonItem?.tintColor = .systemPink
    }

    private func setup() {
        view.addSubview(emptyLabel)
        view.addSubview(messagesTableView)
        view.addSubview(textInputView)
    }

    // MARK: - Layout
    private func layout() {
        navigationBarHeight = (navigationController?.navigationBar.frame.size.height)!
        tabbarHeight = (tabBarController?.tabBar.frame.size.height)!

        emptyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.height.greaterThanOrEqualTo(40)
        }

        messagesTableView.snp.makeConstraints { make in
            make.top.equalTo(navigationBarHeight)
            make.right.left.equalToSuperview()
            make.bottom.equalTo(textInputView.snp.top)
        }

        textInputView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-tabbarHeight)
            make.height.greaterThanOrEqualTo(40)
        }
    }

    // MARK: - Public Methods
    func changeRoomDataSource(with chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        self.viewmodel = ChatRoomViewModel(chatroom: chatRoom)
    }

    // MARK: - Observers
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nudgeReceivedAction(_:)), name: .nudgeReceivedInsideChatRoom, object: nil)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        messagesTableView.addGestureRecognizer(longPressRecognizer)
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    // MARK: - Private Functions
    private func fetchMessagesAndObserve() {
        viewmodel?.fetchMessages(completion: {
            self.toggleEmptyView()
            self.messagesTableView.reloadData()
            self.scrollToBottom()
            print("DEBUG: messages reloaded from didload")
        })
    }

    private func scrollToBottom() {
        if viewmodel?.messages.isEmpty == false {
            let indexPath = IndexPath(row: (viewmodel?.messages.count ?? 0) - 1, section: 0)
            messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    private func toggleEmptyView() {
        if viewmodel?.messages.isEmpty == true {
            emptyLabel.isHidden = false
            messagesTableView.isHidden = true
        } else {
            emptyLabel.isHidden = true
            messagesTableView.isHidden = false
        }
    }

    private func addTitleView() {
        titleView.addSubview(titleViewRoomNameLabel)
        titleView.addSubview(titleViewMemberCountLabel)

        titleViewRoomNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-5)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }

        titleViewMemberCountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleViewRoomNameLabel.snp.bottom).offset(1)
            make.centerX.equalToSuperview()
            make.height.equalTo(12)
        }

        navigationItem.titleView = titleView

        getMemberCount { count in
            self.titleViewMemberCountLabel.text = "\(count == 1 ? "1 member" : " \(count) members")"
        }
    }

    private func getMemberCount(completion: @escaping (Int) -> Void) {
        COLLECTION_CHATROOMS.document(chatRoom?.id ?? "").collection("userIDs").getDocuments { snapshot, error in
            guard let snapshot else { return }
            completion(snapshot.documents.count)
        }
    }

    // MARK: - Actions
    @objc func editRoomSettings() {
        guard let chatRoom = chatRoom else { return }
        let vc = RoomSettingsViewController(chatRoom: chatRoom)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        self.keyboardSize = keyboardSize
        self.isKeyboardOpen = true
        var shouldMoveViewUp = false
        let bottomOfTextField = textInputView.convert(textInputView.bounds, to: self.view).maxY;
        let topOfKeyboard = self.view.frame.height - keyboardSize.height
        if bottomOfTextField > topOfKeyboard {
            shouldMoveViewUp = true
        }
        if(shouldMoveViewUp) {
            let contentInsets = UIEdgeInsets(top: keyboardSize.height - self.navigationBarHeight - self.textInputView.frame.size.height, left: 0.0, bottom: 0.0, right: 0.0)
            // Getting Default Keyboard Animation Config
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self.view.frame.origin.y = 0 - keyboardSize.height + self.tabbarHeight
                self.messagesTableView.contentInset = contentInsets
                self.messagesTableView.scrollIndicatorInsets = contentInsets
            })
        }
    }

    @objc func seeMembersAction() {
        COLLECTION_CHATROOMS.document(chatRoom?.id ?? "").collection("userIDs").getDocuments { snapshot, error in
            guard let snapshot else { return }
            let documents = snapshot.documents
            for item in documents {
                let data = item.data()
                print("DEBUG:-------------", data)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.isKeyboardOpen = false
        self.view.frame.origin.y = 0
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0 , right: 0.0)

        self.messagesTableView.contentInset = contentInsets
        self.messagesTableView.scrollIndicatorInsets = contentInsets
    }

    @objc func backgroundTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc func appEnteredBackground() {
        view.endEditing(true)
    }

    @objc private func nudgeReceivedAction(_ sender: Notification?) {
        guard let sender = sender?.object as? String else { return }
        AlertHelper.simpleAlertMessage(viewController: self, title: "Nudge Received!", message: "\(sender) has sent you a nudge!")
    }

    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            wasKeyboardOpen = isKeyboardOpen
            addBlurEffectView()
            // Finding Cell and adding snapshot to blurview
            let touchPointInTableView = sender.location(in: self.messagesTableView)
            guard let indexPath = self.messagesTableView.indexPathForRow(at: touchPointInTableView)  else { return }
            guard let cell = self.messagesTableView.cellForRow(at: indexPath) as? MessageTableViewCell else { return }
            viewmodel?.selectedMessage = cell.message
            let touchPointInContentView = sender.location(in: self.view)
            guard let cellCopy = cell.snapshotView(afterScreenUpdates: false) else { return }
            blurEffectView.contentView.addSubview(cellCopy)
            self.view.endEditing(true)
            cellCopy.snp.makeConstraints { make in
                if wasKeyboardOpen {
                    make.left.right.equalToSuperview()
                    make.height.equalTo(cell.snp.height)
                    make.centerY.equalToSuperview()
                } else {
                    make.edges.equalTo(cell.snp.edges)
                }
            }
            UIImpactFeedbackGenerator.init(style: .rigid).impactOccurred()
            addCellOptionsTableView(for: cell, under: cellCopy, touchPoint: touchPointInTableView)
        }
    }

    @objc private func addBlurEffectView() {
        blurEffectView.contentView.subviews.forEach({ $0.removeFromSuperview() })
        UIApplication.shared.keyWindow?.addSubview(blurEffectView)
        blurEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        blurEffectView.contentView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(removeBlurEffectView))
        gesture.delegate = self
        blurEffectView.contentView.addGestureRecognizer(gesture)
    }

    @objc private func removeBlurEffectView() {
        blurEffectView.snp.removeConstraints()
        blurEffectView.removeFromSuperview()
        if wasKeyboardOpen {
            textInputView.firstResponderAction()
        }
    }

    @objc private func addCellOptionsTableView(for cell: MessageTableViewCell, under cellCopy: UIView, touchPoint: CGPoint) {
        blurEffectView.contentView.addSubview(messageOptionsTableView)
        
        // Get the cell's frame in the window coordinate system
        guard let window = UIApplication.shared.windows.first else { return }
        let cellFrameInWindow = cell.convert(cell.bounds, to: window)
        
        // Determine if the cell is in the bottom half of the screen
        let screenHeight = window.bounds.height
        let isInBottomHalf = cellFrameInWindow.midY > screenHeight / 2
        
        messageOptionsTableView.snp.makeConstraints { make in
            make.height.equalTo(200)
            make.width.equalTo(100)
            
            if isInBottomHalf {
                // If the cell is in the bottom half, position the table view above the cell
                make.bottom.equalTo(cellCopy.snp.top).offset(-10)
            } else {
                // If the cell is in the top half, position the table view below the cell
                make.top.equalTo(cellCopy.snp.bottom).offset(10)
            }
            
            if cell.isBubbleSideLeft {
                make.left.equalTo(cellCopy.snp.left).offset(5)
            } else {
                make.right.equalTo(cellCopy.snp.right).offset(-5)
            }
        }
    }
}

// MARK: UITableView DataSource
extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == messagesTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.cellIdentifier, for: indexPath) as? MessageTableViewCell else { return UITableViewCell() }
            guard let message = viewmodel?.messages[indexPath.row] else { return UITableViewCell() }
            cell.configureCell(message: message)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageOptionsTableViewCell.cellIdentifier, for: indexPath) as? MessageOptionsTableViewCell else { return UITableViewCell() }
            cell.configureCell(with: indexPath)
            return cell
        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == messagesTableView {
            return viewmodel?.messages.count ?? 0
        } else {
            return 5
        }
    }
}

// MARK: UITableView Delegate
extension ChatRoomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == messageOptionsTableView {
            let cell = tableView.cellForRow(at: indexPath) as? MessageTableViewCell
            switch indexPath.row {
                case 1:
                    guard let message = viewmodel?.selectedMessage else { return }
                    UIPasteboard.general.string = message.message
                    removeBlurEffectView()
                case 2:
                    guard viewmodel?.selectedMessage?.senderUID != AppGlobal.shared.userID else {
                        AlertHelper.alertMessage(title: "Error", message: "You can't report yourself.", okButtonText: "OK")
                        return
                    }
                    AlertHelper.alertMessage(viewController: self, title: "Report", message: "Since all messages are private by default, when you report you choose to send this mesage to our team to investigate. Proceed?") { [weak self] in
                        guard let self = self else { return }
                        self.viewmodel?.reportMessage()
                        AlertHelper.alertMessage(viewController: self, title: "Report has been sent!", message: "Do you want to block this user? Please be aware that this is a destructive process.", okButtonText: "Proceed") {
                            self.viewmodel?.removeUserFromChatRoom()
                            let senderName = self.viewmodel?.selectedMessage?.senderName == "" ? "Anonymous" : self.viewmodel?.selectedMessage?.senderName
                            AlertHelper.alertMessage(title: "Done", message: "You won't get notifications from \(senderName ?? "Anonymous") and they won't be able to interact with the room members from now on. Because they have been removed from the room.", okButtonText: "OK")
                        }
                    }
                default:
                    break
            }
        }
    }
    private func removeUserFromRoom() {
        
    }
}

// MARK: - ChatRoomViewModel Delegate
extension ChatRoomViewController: ChatRoomViewModelDelegate {
    func didChangeDataSource() {
        //
    }
}

// MARK: - TextEntry Delegate
extension ChatRoomViewController: TextEntryViewDelegate {
    func didChangeTextViewSize(height: CGFloat) {
        textInputView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = height
            }
        }
    }

    func didClickSendButton(text: String) {
        guard let viewmodel = viewmodel else { return }
        viewmodel.uploadMessage(message: text)
    }
}

// MARK: - RoomSettings Delegate
extension ChatRoomViewController: RoomSettingsViewControllerDelegate {
    func didDeleteOrBlockRoom() {
        self.navigationController?.popViewController(animated: true)
    }
    func didChangeRoomName(with newName: String) {
        self.titleViewRoomNameLabel.text = newName
    }
}

// MARK: - UIGestureRecognizer Delegate
extension ChatRoomViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint: CGPoint = touch.location(in: messageOptionsTableView)
        return messageOptionsTableView.hitTest(touchPoint, with: nil) == nil
    }
}
