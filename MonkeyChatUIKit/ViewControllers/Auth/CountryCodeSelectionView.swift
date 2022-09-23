//
//  CountryCodeSelectionView.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 19.05.2022.
//

import UIKit
import SnapKit

protocol CountryCodeSelectionViewDelegate: AnyObject {
    func didSelectCountry(countryPhoneExtension: String)
}

class CountryCodeSelectionView: UIView {

    // MARK: - UI Elements
    private lazy var countryNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "-"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.accessibilityIdentifier = "betNameLabel"
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(self.pickerOpenAction(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = "actionButton"
        return button
    }()

    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView(frame: .zero)
        pickerView.dataSource       = self
        pickerView.delegate         = self
//        pickerView.backgroundColor  = UIColor.blue
        pickerView.accessibilityIdentifier = "pickerView"
        return pickerView
    }()

    private lazy var pickerToolBar: UIToolbar = {
        let toolBar = UIToolbar(frame: .zero)
        let doneButton    = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(pickerCloseAction(_:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.monkeyOrange], for: .normal)
//        toolBar.barTintColor = .secondarySystemBackground
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.sizeToFit()
        toolBar.accessibilityIdentifier = "pickerToolBar"
        return toolBar
    }()

    private lazy var dummyTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.accessibilityIdentifier = "dummyTextField"
        return textField
    }()

    // MARK: - Private Properties
    private var pickerViewData = [Country]()

    // MARK: - Public Properties
    weak var delegate: CountryCodeSelectionViewDelegate?

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
        layout()
        configurePickerView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("deinit TJKBetSelectionView")
    }

    // MARK: - Setup & Layout
    private func setup() {
        self.addSubview(countryNameLabel)
        self.addSubview(actionButton)
        self.addSubview(dummyTextField)
    }

    private func layout() {
        self.actionButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.countryNameLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Private Methods
    private func configurePickerView() {
        for code in NSLocale.isoCountryCodes {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])

            let name = NSLocale(localeIdentifier: "en_US").displayName(forKey: NSLocale.Key.identifier, value: id)
            let locale = NSLocale.init(localeIdentifier: id)
            let countryCode = locale.countryCode

            guard name != nil else { continue }
            var country = Country()
            country.name = name
            country.countryCode = countryCode
            country.flag = CountryCodeHelper.findFlagFor(countryCode: countryCode ?? "")
            country.phoneExtensionCode = CountryCodeHelper.extensionCode(countryCode: countryCode ?? "")

            pickerViewData.append(country)
        }
        pickerView.reloadAllComponents()
    }

    // MARK: - Actions
    @objc private func pickerOpenAction(_ sender: UIButton?) {
        dummyTextField.inputView = pickerView
        dummyTextField.inputAccessoryView = pickerToolBar
        dummyTextField.becomeFirstResponder()
    }

    @objc private func pickerCloseAction(_ sender: UIBarButtonItem?) {
        dummyTextField.resignFirstResponder()
        let selectedPickerValue = self.pickerViewData[pickerView.selectedRow(inComponent: 0)]
        self.countryNameLabel.text  = "\(selectedPickerValue.flag ?? "") +\(selectedPickerValue.phoneExtensionCode ?? "")"
        self.delegate?.didSelectCountry(countryPhoneExtension: selectedPickerValue.phoneExtensionCode ?? "")
    }
}

// MARK: - UIPickerView Extension
extension CountryCodeSelectionView: UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerViewData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let country = self.pickerViewData[row]
        return country.name
    }

    //MARK: Delegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Delegate olmadan datasource içi komple soru işareti oluyordu. Boş olsa da ekledim.
    }
}

