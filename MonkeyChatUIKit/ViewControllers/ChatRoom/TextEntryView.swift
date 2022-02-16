//
//  textInputView.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit

class TextEntryView: UIView {

    // MARK: - UI Element
    private let textInputView: UITextView = {
        let textView = UITextView()
        textView.textColor = .red
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isScrollEnabled = false
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.layer.cornerRadius = 10
        return textView
    }()

    private let senButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font =  UIFont(name: "Comic Sans MS", size: 10)
        button.tintColor = .systemPink
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .secondarySystemBackground
        setupLayout()
        addObservers()
    }

    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    // MARK: - Setup & Layout
    private func setupLayout() {
        self.addSubview(textInputView)
        self.addSubview(senButton)

        textInputView.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.left.equalTo(30)
            make.right.equalTo(senButton.snp.left).offset(-30)
            make.height.greaterThanOrEqualTo(40)
            make.bottom.equalTo(-6)
        }
        senButton.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.right.equalTo(self.snp.right).offset(-12)
            make.bottom.equalTo(self.snp.bottom).offset(-6)
            make.width.height.equalTo(40)
        }
    }

    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    // MARK: - Functions
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = self.convert(keyboardScreenEndFrame, from: self.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            textInputView.contentInset = .zero
        } else {
            textInputView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - self.safeAreaInsets.bottom, right: 0)
        }

        textInputView.scrollIndicatorInsets = textInputView.contentInset

        let selectedRange = textInputView.selectedRange
        textInputView.scrollRangeToVisible(selectedRange)
    }
}
