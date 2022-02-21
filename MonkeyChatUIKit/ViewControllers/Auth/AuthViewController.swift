//
//  AuthViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 21.02.2022.
//

import UIKit

class AuthViewController: UIViewController {

    // MARK: - UI Elements
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome To MonkeyChat"
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textColor = UIColor(named: "Black-White")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let phoneInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter your phone number below"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()

    private let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .phonePad
        textField.placeholder = "+1 234 567 890"
        textField.textAlignment = .center
        textField.addTarget(self, action: #selector(signIn), for: .editingChanged)
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
        view.backgroundColor = .systemBackground

        let gesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(gesture)
    }

    // MARK: - Setup
    func setup() {
        view.addSubview(welcomeLabel)
        view.addSubview(phoneInfoLabel)
        view.addSubview(phoneTextField)
    }

    func layout() {
        welcomeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-100)
            make.height.greaterThanOrEqualTo(60)
            make.left.right.equalToSuperview()
        }

        phoneInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(10)
            make.height.equalTo(40)
            make.left.right.equalToSuperview()
        }

        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneInfoLabel.snp.bottom).offset(10)
            make.height.equalTo(40)
            make.left.right.equalToSuperview()
        }
    }

    func setDelegates() {
        phoneTextField.delegate = self
    }

    // MARK: - Actions
    @objc func endEditing() {
        phoneTextField.endEditing(true)
    }

    // MARK: - Private Methods
    @objc func signIn() {
        if phoneTextField.text?.count == 13 {
            AlertHelper.alertMessage(viewController: self,title: "Check Your Number", message: "Your number is \(phoneTextField.text ?? ""). Continue?") {
                LottieHUD.shared.show()
                guard let phoneNumber = self.phoneTextField.text else { return }
                AuthManager.shared.startAuth(phoneNumber: phoneNumber) { [weak self] success in
                    guard success else { return }
                    guard let self = self else { return }
                    let viewController = VerificationCodeViewController()
                    viewController.modalPresentationStyle = .fullScreen
                    self.present(viewController, animated: true, completion: nil)
                    LottieHUD.shared.dismiss()
                }
            }
        }
    }
}

//MARK: - UITextFieldDelegate
extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneTextField {
            //
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
