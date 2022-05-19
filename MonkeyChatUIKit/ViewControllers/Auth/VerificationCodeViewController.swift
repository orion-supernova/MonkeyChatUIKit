//
//  VerificationCodeViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 21.02.2022.
//

import UIKit

class VerificationCodeViewController: UIViewController {

    //MARK: - UI Elements
    private lazy var verificationInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Please Enter Your Verification Code"
        label.textAlignment = .center
        return label
    }()

    private lazy var verificationCodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Verification Code"
        textField.textAlignment = .center
        textField.addTarget(self, action: #selector(verifyCode), for: .editingChanged)
        return textField
    }()

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        layout()
        setDelegates()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = .systemBackground
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        verificationCodeTextField.becomeFirstResponder()
    }

    //MARK: - Setup
    func setup() {
        view.addSubview(verificationCodeTextField)
        view.addSubview(verificationInfoLabel)
    }

    func layout() {
        verificationInfoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-200)
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }

        verificationCodeTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-100)
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }
    }

    func setDelegates() {
        verificationCodeTextField.delegate = self
    }

    //MARK: - Actions
    @objc func verifyCode() {
        if verificationCodeTextField.text?.count == 6 {
            verificationCodeTextField.endEditing(true)
            LottieHUD.shared.show()
            guard let smsCode = self.verificationCodeTextField.text else { return }
            AuthManager.shared.verifyCodeAndSignIn(smsCode: smsCode) { [weak self] success in
                guard let self = self else { return }
                guard success else {
                    LottieHUD.shared.dismiss()
                    DispatchQueue.main.async {
                        AlertHelper.alertMessage(viewController: self, title: "Error", message: "Please check your code or try again later.") {
                            //
                        }
                    }
                    return
                }
                self.configureLoginView { tabBar in
                    let tabController = tabBar
                    tabController.modalPresentationStyle = .fullScreen
                    self.present(tabController, animated: true, completion: nil)
                    LottieHUD.shared.dismiss()
                }
            }
        }
    }
    //MARK: - Functions
    func configureLoginView(completion: @escaping (UITabBarController) -> Void) {
        let tabController = UITabBarController()
        let vc1 = UINavigationController(rootViewController: ChatRoomListViewController())
        let vc2 = UINavigationController(rootViewController: SettingsViewController())
        tabController.viewControllers = [vc1, vc2]
        tabController.tabBar.tintColor = .systemPink

        vc1.tabBarItem.image = UIImage(systemName: "list.bullet")
        vc2.tabBarItem.image = UIImage(systemName: "gear")

        vc1.title = "MonkeyList"
        vc2.title = "Settings"
        completion(tabController)
    }
}

//MARK: - UITextFieldDelegate
extension VerificationCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == verificationCodeTextField {
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
        return updatedText.count <= 6
    }

}
