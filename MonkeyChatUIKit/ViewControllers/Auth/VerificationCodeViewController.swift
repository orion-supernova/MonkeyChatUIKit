//
//  VerificationCodeViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 21.02.2022.
//

import UIKit
import RiveRuntime

class VerificationCodeViewController: UIViewController {

    // MARK: - UI Elements
    private lazy var animationBackgroundView: RiveView = {
        let view = RiveView()
        riveViewModel.setView(view)
        riveViewModel.fit = Fit.fitCover
        return view
    }()
    
    private lazy var verificationInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Please Enter Your Verification Code"
        label.textAlignment = .center
        return label
    }()

    private lazy var verificationCodeView: OTPStackView = {
        let view = OTPStackView()
        view.delegate = self
        return view
    }()

    // MARK: - Private Variables
    private lazy var riveViewModel = RiveViewModel(fileName: "safe_box_icon", stateMachineName: "State Machine 1")

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        layout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.backgroundColor = .systemBackground
        overrideUserInterfaceStyle = .dark
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

    // MARK: - Setup
    func setup() {
        view.addSubview(animationBackgroundView)
        animationBackgroundView.addSubview(verificationInfoLabel)
        animationBackgroundView.addSubview(verificationCodeView)
    }

    func layout() {
        animationBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        verificationInfoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-200)
            make.width.equalToSuperview()
            make.height.equalTo(40)
        }

        verificationCodeView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-100)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
    }

    //MARK: - Actions
    @objc func verifyCode(with code: String) {
        LottieHUD.shared.show()
        AuthManager.shared.verifyCodeAndSignIn(smsCode: code) { [weak self] success in
            guard let self = self else { return }
            guard success else {
                LottieHUD.shared.dismiss()
                DispatchQueue.main.async {
                    AlertHelper.simpleAlertMessage(viewController: self, title: "Error", message: "Please check your code or try again later.") {
                        self.verificationCodeView.resetOTPString()
                    }
                }
                return
            }
            LottieHUD.shared.dismiss()
            self.riveViewModel.triggerInput("Pressed")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                // Redirect to EULA Page if the user did not accept yet.
                let confirmed = AppGlobal.shared.eulaConfirmed ?? false
                guard confirmed else {
                    let viewController = EULAViewController()
                    viewController.modalPresentationStyle = .fullScreen
                    viewController.modalTransitionStyle = .crossDissolve
                    self.present(viewController, animated: true, completion: nil)
                    self.riveViewModel.resetToDefaultModel()
                    return
                }
                // If there is no problem, navigate to MainPage
                self.configureLoginView { tabBar in
                    let tabController = tabBar
                    tabController.modalPresentationStyle = .fullScreen
                    tabController.modalTransitionStyle = .crossDissolve
                    self.present(tabController, animated: true, completion: nil)
                    self.riveViewModel.resetToDefaultModel()
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

extension VerificationCodeViewController: OTPDelegate {
    func didStartRequestWith(OTP: String) {
        verifyCode(with: OTP)
    }
}
