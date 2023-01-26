//
//  UsernameViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 21.02.2022.
//

import UIKit

protocol UsernameViewControllerDelegate: AnyObject {
    func didChangeUsername(with username: String)
}

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

    // MARK: - Public Properties
    weak var delegate: UsernameViewControllerDelegate?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        layout()
        setDelegates()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        usernameTextField.layer.cornerRadius = 10
    }

    // MARK: - Setup
    private func setup() {
        self.view.backgroundColor = UIColor(named: "White-Black")
        view.addSubview(usernameTextField)
    }

    private func layout() {
        usernameTextField.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }
    }

    private func setDelegates() {
        usernameTextField.delegate = self
    }

    // MARK: - Private Functions
    private func changeUsername() {
        AppGlobal.shared.username = usernameTextField.text
        COLLECTION_USERS.document(AppGlobal.shared.userID ?? "").updateData(["username": usernameTextField.text ?? ""])

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
            self.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.delegate?.didChangeUsername(with: self.usernameTextField.text ?? "")
            }
        }
        return true
    }
}
