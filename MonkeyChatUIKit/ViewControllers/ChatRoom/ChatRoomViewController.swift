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
        textView.textColor = .red
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isScrollEnabled = false
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.layer.cornerRadius = 10
        textView.layer.zPosition = 1
        return textView
    }()

    private let textfield: UITextField = {
        let textfield = UITextField()
        textfield.font = UIFont.systemFont(ofSize: 17)
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType = .none
        textfield.layer.cornerRadius = 10
        textfield.backgroundColor = .systemBackground
        return textfield
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font =  UIFont(name: "Comic Sans MS", size: 10)
        button.tintColor = .systemPink
        button.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
        return button
    }()

    private let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()

    // MARK: - Private Properties
    var chatRoom: ChatRoom?
    var activeTextField : UITextField? = nil
    var navigationBarHeight: CGFloat = 0
    var viewmodel: ChatRoomViewModel?


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
        self.title = "Chat Room: \(chatRoom?.name ?? "")"
        self.navigationController?.navigationBar.tintColor = .systemPink
    }

    override func viewDidAppear(_ animated: Bool) {

    }

    //MARK: - Setup
    private func setTableViewDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        textInputView.delegate = self
        textfield.delegate = self
    }

    func setup() {
        view.addSubview(tableView)
        view.addSubview(bottomView)
//        bottomView.addSubview(textInputView)
        bottomView.addSubview(textfield)
        bottomView.addSubview(sendButton)
    }

    // MARK: - Layout
    func layout() {
        navigationBarHeight = navigationController?.navigationBar.frame.maxY ?? 100

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-navigationBarHeight+10)
            make.height.equalTo(50)
        }

//        textInputView.snp.makeConstraints { make in
//            make.left.equalTo(30)
//            make.right.equalTo(sendButton.snp.left).offset(-30)
//            make.height.greaterThanOrEqualTo(40)
//            make.bottom.equalTo(-5)
//        }

        textfield.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(sendButton.snp.left).offset(-30)
            make.height.greaterThanOrEqualTo(40)
            make.bottom.equalTo(-5)
        }

        sendButton.snp.makeConstraints { make in
            make.right.equalTo(view.snp.right).offset(-12)
            make.bottom.equalTo(-5)
            make.width.height.equalTo(40)
        }

    }

    // MARK: - Functions
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    func fetchMessagesAndObserve() {
        viewmodel?.fetchMessages(completion: {
            self.tableView.reloadData()
            print("DEBUG: messages reloaded from didload")
        })
    }



    // MARK: - Actions
    @objc func sendButtonAction() {
        guard let viewmodel = viewmodel else { return }
        viewmodel.uploadMessage(message: textfield.text ?? "")
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

            // if keyboard size is not available for some reason, dont do anything
           return
        }

        var shouldMoveViewUp = false

        // if active text field is not nil
        if let activeTextField = activeTextField {

            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
            let topOfKeyboard = self.view.frame.height - keyboardSize.height

            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
        }

        if(shouldMoveViewUp) {
            self.view.frame.origin.y = 0 - keyboardSize.height + navigationBarHeight-10
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
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
//        return 50
        return viewmodel?.messages.count ?? 0
    }
}

// MARK: UITableViewDelegate
extension ChatRoomViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ChatRoomViewController: UITextViewDelegate, UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
}
// MARK: - ChatRoomViewModelDelegate
extension ChatRoomViewController: ChatRoomViewModelDelegate {
    func didChangeDataSource() {
        //
    }
}
