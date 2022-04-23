//
//  UsernameViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 21.02.2022.
//

import UIKit

class UsernameViewController: UIViewController {

    // MARK: - UI Elements
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        if AppGlobal.shared.username == "" {
            textField.placeholder = "Username"
        } else {
            textField.placeholder = AppGlobal.shared.username
        }
        textField.autocapitalizationType = .none
        textField.textAlignment = .center
        textField.returnKeyType = .done
        textField.backgroundColor = .secondarySystemBackground
        textField.becomeFirstResponder()
        return textField
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        layout()
        setDelegates()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    // MARK: - Setup
    func setup() {
        view.addSubview(usernameTextField)
    }

    func layout() {
        usernameTextField.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }
    }

    func setDelegates() {
        usernameTextField.delegate = self
    }

    // MARK: - Private Functions
    func changeUsername() {
        AppGlobal.shared.username = usernameTextField.text
    }
}

// MARK: - UITextFieldDelegate
extension UsernameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            textField.endEditing(true)
            changeUsername()
            navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name("reloadTableView"), object: nil)
        }
        return true
    }
}
