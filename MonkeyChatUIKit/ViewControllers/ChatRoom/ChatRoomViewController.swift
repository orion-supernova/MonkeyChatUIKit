//
//  ChatRoomViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit

class ChatRoomViewController: UIViewController {

     // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    private let textInputView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isScrollEnabled = false
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.layer.cornerRadius = 10
        textView.layer.zPosition = 1
        return textView
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font =  UIFont(name: "Comic Sans MS", size: 10)
        button.tintColor = .systemPink
        button.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()

    // MARK: - Private Properties
    var chatRoom: ChatRoom?
    var activeTextView : UITextView? = nil
    var navigationBarHeight: CGFloat = 0
    var tabbarHeight: CGFloat = 0
    var viewmodel: ChatRoomViewModel?
    var keyboardDispatchGroup: DispatchGroup?

    // MARK: - Lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        super.init(nibName: nil, bundle: nil)
        self.viewmodel = ChatRoomViewModel(chatroom: chatRoom)
    }
    deinit {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillHideNotification)
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillChangeFrameNotification)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setTableViewDelegates()
        layout()
        addObservers()
        fetchMessagesAndObserve()
    }

    override func viewDidLayoutSubviews() {
        self.title = chatRoom?.name ?? ""
        self.navigationController?.navigationBar.tintColor = .systemPink

        let editRoomSettingsButton = UIBarButtonItem(barButtonSystemItem: .edit,
                                                   target: self,
                                                   action: #selector(editRoomSettings))
        navigationItem.rightBarButtonItems = [editRoomSettingsButton]
        navigationItem.rightBarButtonItem?.tintColor = .systemPink
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

    func setup() {
        view.addSubview(tableView)
        view.addSubview(bottomView)
        bottomView.addSubview(textInputView)
        bottomView.addSubview(sendButton)
    }

    // MARK: - Layout
    func layout() {
        navigationBarHeight = (navigationController?.navigationBar.frame.size.height)!
        tabbarHeight = (tabBarController?.tabBar.frame.size.height)!


        tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationBarHeight)
            make.right.left.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }

        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-tabbarHeight)
            make.height.equalTo(50)
        }

        textInputView.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(sendButton.snp.left).offset(-30)
            make.height.equalTo(40)
            make.bottom.equalTo(-5)
        }

        sendButton.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.bottom.equalTo(-5)
            make.width.height.equalTo(40)
        }

    }

    // MARK: - Actions
    @objc func editRoomSettings() {
        guard let chatRoom = chatRoom else { return }
        var alertMessage = ""
        guard let tempPassword = chatRoom.password else { return }
        if tempPassword != "" {
            alertMessage = "Password: \(tempPassword)"
        } else {
            alertMessage = "Password: Not Configured"
        }
        guard let chatRoomID = chatRoom.id else { return }
        UIPasteboard.general.string = chatRoomID
        let alertController = UIAlertController(title: "Room ID copied to your clipboard", message: "Room ID: \(chatRoomID) \n" + alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in
            //
        }
        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Functions
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        self.keyboardDispatchGroup = DispatchGroup()
    }

    func fetchMessagesAndObserve() {
        viewmodel?.fetchMessages(completion: {
            self.tableView.reloadData()
            self.scrollToBottom()
            print("DEBUG: messages reloaded from didload")
        })
    }

    func scrollToBottom() {
        if viewmodel?.messages.isEmpty == false {
            let indexPath = IndexPath(row: (viewmodel?.messages.count ?? 0) - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    // MARK: - Actions
    @objc func sendButtonAction() {
        guard let viewmodel = viewmodel else { return }
        viewmodel.uploadMessage(message: textInputView.text ?? "")
        self.textInputView.text = ""
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        keyboardDispatchGroup?.notify(queue: .main, execute: { [weak self] in
            guard let self = self else { return }

            guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                // if keyboard size is not available for some reason, dont do anything
                return
            }
            var shouldMoveViewUp = false

            // if active text field is not nil
            if let activeTextField = self.activeTextView {

                let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
                let topOfKeyboard = self.view.frame.height - keyboardSize.height

                if bottomOfTextField > topOfKeyboard {
                    shouldMoveViewUp = true
                }
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
        })
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0 , right: 0.0)

        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }

    @objc func backgroundTap(_ sender: UITapGestureRecognizer) {
        // go through all of the textfield inside the view, and end editing thus resigning first responder
        // ie. it will trigger a keyboardWillHide notification
        self.view.endEditing(true)
    }
}

// MARK: UITableViewDataSource
extension ChatRoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as? MessageTableViewCell else { return UITableViewCell() }
        cell.textLabel?.text = viewmodel?.messages[indexPath.row].message
        cell.textLabel?.numberOfLines = 0
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel?.messages.count ?? 0
    }
}

// MARK: UITableViewDelegate
extension ChatRoomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: UITextViewDelegate
extension ChatRoomViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        keyboardDispatchGroup?.enter()
        self.activeTextView = textView
        keyboardDispatchGroup?.leave()
        textViewDidChange(textView)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.activeTextView = nil
    }

    func textViewDidChange(_ textView: UITextView) {
        var textInputViewWidth: CGFloat = 0

        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width {
                textInputViewWidth = constraint.constant
            }
        }
        let size = CGSize(width: textInputViewWidth, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)

        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
        self.bottomView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height + 10
            }
        }
        var notNullOrEmptyString = false
        for item in textView.text {
            if item != " " {
                notNullOrEmptyString = true
            }
        }
        sendButton.isEnabled = notNullOrEmptyString && textView.text != ""
    }
}

// MARK: - ChatRoomViewModelDelegate
extension ChatRoomViewController: ChatRoomViewModelDelegate {
    func didChangeDataSource() {
        //
    }
}
