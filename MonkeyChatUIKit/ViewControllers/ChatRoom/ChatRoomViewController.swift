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

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var textInputView: TextEntryView = {
        let view = TextEntryView(frame: .zero, viewController: self)
        return view
    }()

    // MARK: - Private Properties
    private var chatRoom: ChatRoom?
    private var activeTextView : UITextView? = nil
    private var navigationBarHeight: CGFloat = 0
    private var tabbarHeight: CGFloat = 0
    private var viewmodel: ChatRoomViewModel?

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
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillChangeFrameNotification)
        NotificationCenter.default.removeObserver(UIApplication.didEnterBackgroundNotification)
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
    }

    //MARK: - Setup
    private func setTableViewDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        textInputView.delegate = self
    }

    private func configureNavigationBar() {
        self.title = chatRoom?.name ?? ""
        self.navigationController?.navigationBar.tintColor = .systemPink
        let editRoomSettingsButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(editRoomSettings))
        navigationItem.rightBarButtonItems = [editRoomSettingsButton]
        navigationItem.rightBarButtonItem?.tintColor = .systemPink
    }

    private func setup() {
        view.addSubview(emptyLabel)
        view.addSubview(tableView)
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

        tableView.snp.makeConstraints { make in
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

    // MARK: - Actions
    @objc func editRoomSettings() {
        guard let chatRoom = chatRoom else { return }
        let vc = RoomSettingsViewController(chatRoom: chatRoom)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Private Functions
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnteredBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func fetchMessagesAndObserve() {
        viewmodel?.fetchMessages(completion: {
            self.toggleEmptyView()
            self.tableView.reloadData()
            self.scrollToBottom()
            print("DEBUG: messages reloaded from didload")
        })
    }

    private func scrollToBottom() {
        if viewmodel?.messages.isEmpty == false {
            let indexPath = IndexPath(row: (viewmodel?.messages.count ?? 0) - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    private func toggleEmptyView() {
        if viewmodel?.messages.isEmpty == true {
            emptyLabel.isHidden = false
            tableView.isHidden = true
        } else {
            emptyLabel.isHidden = true
            tableView.isHidden = false
        }
    }

    // MARK: - Actions
    @objc func keyboardWillShow(notification: NSNotification) {

        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
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
                self.tableView.contentInset = contentInsets
                self.tableView.scrollIndicatorInsets = contentInsets
            })
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0 , right: 0.0)

        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }

    @objc func backgroundTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc func appEnteredBackground() {
        view.endEditing(true)
    }
}

// MARK: UITableView DataSource
extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as? MessageTableViewCell else { return UITableViewCell() }
        guard let message = viewmodel?.messages[indexPath.row] else { return UITableViewCell() }
        cell.configureCell(message: message)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel?.messages.count ?? 0
    }
}

// MARK: UITableView Delegate
extension ChatRoomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
}
