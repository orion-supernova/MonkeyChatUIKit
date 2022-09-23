//
//  OTPStackView.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 19.05.2022.
//

import UIKit
import SnapKit

protocol OTPDelegate: AnyObject {
    func didStartRequestWith(OTP: String)
}

class OTPStackView: UIStackView {

    // MARK: - Private Properties
    private let numberOfFields = 6
    private var textFieldsCollection: [OTPTextField] = []
    private var isThisFirstTimeForOTP = true

    // MARK: - Public Properties
    weak var delegate: OTPDelegate?

    // MARK: - Lifecycle
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        addOTPTextFields()
    }

    // MARK: - Setup
    private func setup() {
        self.backgroundColor = .clear
        self.contentMode = .center
        self.distribution = .fillEqually
        self.spacing = 15
    }

    // MARK: - Private Functions
    private func addOTPTextFields() {
        for index in 0..<numberOfFields{
            let textFieldView = OTPTextFieldWithUnderlineView(frame: .zero)
            self.addArrangedSubview(textFieldView)

            let textField = textFieldView.textField
            textField.delegate = self
            textFieldsCollection.append(textField)

            // TextField'ın altındaki çizgi renginin diğerlerinden bağımsız değişmesi için tek tek ekliyoruz.
            textField.textFieldUnderlineView = textFieldView.textFieldUnderlineView

            // Koleksiyona eklenen textField'ın bir önceki ve bir sonraki field'ı tanıması sağlanır.
            index == 0 ? (textField.previousTextField = nil) : (textField.previousTextField = textFieldsCollection[index-1])
            index == 0 ? () : (textFieldsCollection[index-1].nextTextField = textField)
        }
        textFieldsCollection.first?.becomeFirstResponder()
    }

    //Bütün OTP alanlarının dolup dolmadığını kontrol eder. Hepsi doluysa delegate fonksiyonunu çağırır.
    private func checkForCompletion(){
        for field in textFieldsCollection{
            if (field.text == ""){
                return
            }
        }
        let otpString = self.getOTP()
        delegate?.didStartRequestWith(OTP: otpString)
    }

    // OTP Alanındaki texti getirir.
    private func getOTP() -> String {
        var OTP = ""
        for textField in textFieldsCollection{
            OTP += textField.text ?? ""
        }
        return OTP
    }

    // MARK: - Public Functions
    func resetOTPString() {
        for textField in textFieldsCollection {
            textField.text = ""
            textField.textFieldUnderlineView?.backgroundColor = .white
        }
        textFieldsCollection.first?.becomeFirstResponder()
    }
}

// MARK: - TextField Delegate
extension OTPStackView: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        checkForCompletion()
    }

    // OTP alanları arasında hareket eder.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range:NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? OTPTextField else { return true }
        switch string.count {
            case 1:
                if textField.nextTextField == nil {
                    textField.text? = string
                    textField.resignFirstResponder()
                } else {
                    textField.text? = string
                    textField.nextTextField?.becomeFirstResponder()
                }
                textField.textFieldUnderlineView?.backgroundColor = UIColor.init(hexString: "CC8899")
            default:
                break
        }
        return true
    }
}

// MARK: - CLASS OTP TEXTFIELD
class OTPTextField: UITextField {
    weak var previousTextField: OTPTextField?
    weak var nextTextField: OTPTextField?
    weak var textFieldUnderlineView: UIView?

    override func deleteBackward() {
        if self.text == "" || self.text == nil {
            previousTextField?.text = ""
            previousTextField?.textFieldUnderlineView?.backgroundColor = UIColor.init(hexString: "d0d0d0")
            previousTextField?.becomeFirstResponder()
        } else {
            self.text = ""
            self.textFieldUnderlineView?.backgroundColor = UIColor.init(hexString: "d0d0d0")
        }
    }
}

// MARK: - CLASS OTP TEXTFIELD WITH UNDERLINE VIEW
class OTPTextFieldWithUnderlineView: UIView {
    // MARK: - UI Elements
    var textField: OTPTextField = {
        let textField = OTPTextField()
        textField.backgroundColor = .clear
        textField.tintColor = UIColor.init(hexString: "CC8899")
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: 32)
        textField.keyboardType = .numberPad
        return textField
    }()

    var textFieldUnderlineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(hexString: "d0d0d0")
        return view
    }()

    // MARK: - Lifecycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        layout()
    }

    deinit {
        print("OTPTextFieldWithUnderlineView deinit")
    }

    // MARK: - Private Methods
    private func setup() {
        self.addSubview(textField)
        self.addSubview(textFieldUnderlineView)
    }

    private func layout() {
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(44)
        }

        textFieldUnderlineView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(2)
        }
    }
}
