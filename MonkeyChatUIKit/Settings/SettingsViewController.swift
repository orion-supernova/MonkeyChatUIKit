//
//  SettingsViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    // MARK: - UI Elements
    private let profilePictureView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        return imageView
    }()

    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.textAlignment = .center
        textField.returnKeyType = .done
        return textField
    }()

    var notificationsCheckbox: UIButton = {
        let button = NotificationsCheckBox(type: .system)
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.addTarget(self, action: #selector(checkBoxAction), for: .touchUpInside)
        return button
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.tintColor = .systemPink
        button.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Private Properties
    let currentUserString = UserDefaults.standard.string(forKey: "currentUser")
    let viewmodel = SettingsViewModel()
    var isChecked: Bool = true {
        didSet {
            if isChecked == true {
                notificationsCheckbox.setImage(UIImage(systemName: "bell"), for: .normal)
            } else {
                notificationsCheckbox.setImage(UIImage(systemName: "bell.slash"), for: .normal)
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        layout()
    }

    override func viewDidLayoutSubviews() {
        self.title = "Settings"
        view.backgroundColor = .systemBackground
    }

    // MARK: - Lifecycle
    func setup() {
        view.addSubview(profilePictureView)
        view.addSubview(usernameTextField)
        view.addSubview(notificationsCheckbox)
        view.addSubview(logoutButton)
    }

    func layout() {
        let navigationBarHeight = (navigationController?.navigationBar.frame.size.height)!

        profilePictureView.snp.makeConstraints { make in
            make.top.equalTo(navigationBarHeight*2)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(80)
        }

        usernameTextField.snp.makeConstraints { make in
            make.top.equalTo(profilePictureView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }

        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(usernameTextField.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(30)
        }
    }

    // MARK: - Actions
    @objc func checkBoxAction() {
        // If the user is registered, remove it and vice versa.
        if isChecked {
            viewmodel.unsubscribeForNewMessages()
        } else {
            viewmodel.subscribeForNewMessages(showAlert: true)
        }
        isChecked = !isChecked
    }

    @objc func logoutAction() {
        LottieHUD.shared.show()
        AuthManager.shared.signOut {
            let viewController = AuthViewController()
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
            LottieHUD.shared.dismiss()
        }
    }
}

//MARK: - UITextFieldDelegate
extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            guard let username = textField.text else { return false }
            viewmodel.changeUsername(username: username)
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // make sure the result is under 16 characters
        return updatedText.count <= 13
    }

}
