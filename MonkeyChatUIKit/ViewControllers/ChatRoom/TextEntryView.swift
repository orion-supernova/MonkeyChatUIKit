//
//  textInputView.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import SnapKit

protocol TextEntryViewDelegate: AnyObject {
    func didClickSendButton(text: String)
    func didChangeTextViewSize(height: CGFloat)
}

class TextEntryView: UIView {

    enum SendButtonState {
        case enabled
        case disabled
    }

    // MARK: - UI Element
    private lazy var attachmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.tintColor = .tertiaryLabel
        button.addTarget(self, action: #selector(attachmentButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = true
        textView.layer.cornerRadius = 10
        textView.delegate = self
        return textView
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font =  UIFont(name: "Comic Sans MS", size: 10)
        button.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Public Variables
    weak var delegate: TextEntryViewDelegate?

    // MARK: - Private Properties
    private var viewController: UIViewController?

    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .secondarySystemBackground
        setupLayout()
        setSendButtonState(state: .disabled)
    }

    convenience init(frame: CGRect, viewController: UIViewController) {
        self.init(frame: frame)
        self.viewController = viewController
    }

    // MARK: - Setup & Layout
    private func setupLayout() {
        self.addSubview(attachmentButton)
        self.addSubview(textView)
        self.addSubview(sendButton)

        attachmentButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.size.equalTo(30)
        }

        textView.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.left.equalTo(attachmentButton.snp.right).offset(5)
            make.right.equalTo(sendButton.snp.left).offset(-5)
            make.bottom.equalTo(-6)
        }
        
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.right.equalTo(self.snp.right).offset(-6)
            make.bottom.equalTo(self.snp.bottom).offset(-6)
            make.width.height.equalTo(40)
        }
    }

    // MARK: - Private Methods
    private func setSendButtonState(state: SendButtonState) {
        switch state {
            case .enabled:
                sendButton.tintColor = .systemPink
                sendButton.isEnabled = true
            case .disabled:
                sendButton.tintColor = .tertiaryLabel
                sendButton.isEnabled = false
        }
    }

    // MARK: - Actions
    @objc func attachmentButtonAction() {
        guard let viewController = viewController else {
            return
        }
        AlertHelper.simpleAlertMessage(viewController: viewController, title: "LOL", message: "Olcak olcak pek yakında...")
    }

    @objc func sendButtonAction() {
        let firstNonEmptyChar = textView.text.first(where: { $0 != " " && $0 != "\n"})
        while textView.text.first != firstNonEmptyChar {
            textView.text.removeFirst()
        }
        while textView.text.last == " " || textView.text.last == "\n" {
            textView.text.removeLast()
        }
        delegate?.didClickSendButton(text: textView.text)
        self.textView.text = ""
        self.textViewDidChange(self.textView)
    }
}

// MARK: UITextView Delegate
extension TextEntryView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize (width: textView.frame.size.width, height: .infinity)
        let estimatedHeight = textView.sizeThatFits(size).height * 1.25
        guard textView.contentSize.height < 100.0 else {
            textView.isScrollEnabled = true
            return
        }
        textView.isScrollEnabled = false
        delegate?.didChangeTextViewSize(height: estimatedHeight)

        var notNullOrEmptyString = false
        for item in textView.text {
            if item != " " && item != "\n" {
                notNullOrEmptyString = true
            }
        }
        (notNullOrEmptyString && textView.text != "") ? setSendButtonState(state: .enabled) : setSendButtonState(state: .disabled)
    }
}
