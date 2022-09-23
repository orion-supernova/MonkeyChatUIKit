//
//  AuthViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 21.02.2022.
//

import UIKit
import SnapKit
import RiveRuntime

class AuthViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var animationBackgroundView: RiveView = {
        let view = RiveView()
        riveViewModel.setView(view)
        riveViewModel.fit = Fit.fitCover
        return view
    }()

    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome To MonkeyChat"
        label.font = .systemFont(ofSize: 25, weight: .bold)
        label.textColor = UIColor(named: "Black-White")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var phoneInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter your phone number below"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var countryCodeSelectionView: CountryCodeSelectionView = {
        let view = CountryCodeSelectionView()
        view.delegate = self
        view.backgroundColor = .clear
        return view
    }()

    private lazy var phoneTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .phonePad
        textField.placeholder = " Phone Number"
        textField.font = .systemFont(ofSize: 14)
        textField.delegate = self
        return textField
    }()

    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Fire Up", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(UIColor.monkeyOrange, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        return button
    }()

    // MARK: - Private variables
    private lazy var userCountryCode = ""
    private lazy var userFullNumber = ""
    private lazy var riveViewModel = RiveViewModel(fileName: "lights")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = .systemBackground

        let gesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(gesture)
    }


    // MARK: - Setup
    func setup() {
        view.addSubview(animationBackgroundView)
        animationBackgroundView.addSubview(welcomeLabel)
        animationBackgroundView.addSubview(phoneInfoLabel)
        animationBackgroundView.addSubview(countryCodeSelectionView)
        animationBackgroundView.addSubview(phoneTextField)
        animationBackgroundView.addSubview(dividerView)
        animationBackgroundView.addSubview(sendButton)
    }

    func layout() {
        animationBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        welcomeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-150)
            make.height.greaterThanOrEqualTo(60)
            make.left.right.equalToSuperview()
        }

        phoneInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(10)
            make.height.equalTo(40)
            make.left.right.equalToSuperview()
        }

        countryCodeSelectionView.snp.makeConstraints { make in
            make.top.equalTo(phoneInfoLabel.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(40)
        }

        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneInfoLabel.snp.bottom).offset(10)
            make.height.equalTo(40)
            make.left.equalTo(countryCodeSelectionView.snp.right)
            make.right.equalToSuperview()
        }

        dividerView.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(2)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }

        sendButton.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom).offset(10)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(20)
        }
    }

    // MARK: - Private Methods
    @objc func signIn() {
        self.endEditing()
        checkForValidity { valid in
            guard valid else { return }
        }
        AlertHelper.alertMessage(viewController: self,title: "Check Your Number", message: "Your number is (\(userCountryCode )) \(phoneTextField.text ?? ""). Continue?") { [weak self] in
            guard let self = self else { return }
            LottieHUD.shared.show()
            let phoneNumber = self.userCountryCode + (self.phoneTextField.text ?? "")
            AuthManager.shared.startAuth(phoneNumber: phoneNumber) { success in
                guard success else {
                    LottieHUD.shared.dismiss()
                    AlertHelper.simpleAlertMessage(viewController: self, title: "Error", message: "Please check your number or try again later.")
                    return
                }
                let viewController = VerificationCodeViewController()
                viewController.modalPresentationStyle = .fullScreen
                self.present(viewController, animated: true, completion: nil)
                LottieHUD.shared.dismiss()
            }
        }
    }

    private func checkForValidity(completion: ((Bool) -> Void)) {
        guard !userCountryCode.isEmpty else {
            AlertHelper.simpleAlertMessage(viewController: self, title: "Error", message: "Please choose your country code.")
            completion(false)
            return
        }
        guard phoneTextField.text != "", phoneTextField.text != nil else {
            AlertHelper.simpleAlertMessage(viewController: self, title: "Error", message: "Please enter your phone number.")
            completion(false)
            return
        }
        completion(true)
    }

    // MARK: - Actions
    @objc func endEditing() {
        phoneTextField.endEditing(true)
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

        // make sure the result is under 20 characters
        return updatedText.count <= 20
    }

}

extension AuthViewController: CountryCodeSelectionViewDelegate {
    func didSelectCountry(countryPhoneExtension: String) {
        userCountryCode = "+\(countryPhoneExtension)"
    }
}
