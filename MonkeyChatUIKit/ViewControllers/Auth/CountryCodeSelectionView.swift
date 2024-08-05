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
        label.text = "+123"
        label.textColor = .init(hexString: "#5D4F64")
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
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.accessibilityIdentifier = "pickerView"
        return pickerView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search countries"
        searchBar.delegate = self
        searchBar.accessibilityIdentifier = "countrySearchBar"
        searchBar.searchBarStyle = .default
        searchBar.backgroundColor = .clear
        searchBar.setShowsCancelButton(false, animated: false)
        return searchBar
    }()
    
    private lazy var pickerToolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(pickerCloseAction(_:)))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pickerCloseWithoutAction))
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.monkeyOrange], for: .normal)
        cancelButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.monkeyOrange], for: .normal)
        
        // Create a container view for the search bar
        let searchContainer = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 44))
        searchBar.frame = searchContainer.bounds
        searchContainer.addSubview(searchBar)
        
        let searchBarButton = UIBarButtonItem(customView: searchContainer)
        
        toolBar.setItems([cancelButton, flexibleSpace, searchBarButton, flexibleSpace, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
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
    private var filteredPickerViewData = [Country]()
    
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
        print("deinit CountryCodeSelectionView")
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
            
            guard let name = name else { continue }
            var country = Country()
            country.name = name
            country.countryCode = countryCode
            country.flag = CountryCodeHelper.findFlagFor(countryCode: countryCode ?? "")
            country.phoneExtensionCode = CountryCodeHelper.extensionCode(countryCode: countryCode ?? "")
            
            pickerViewData.append(country)
        }
        filteredPickerViewData = pickerViewData
        pickerView.reloadAllComponents()
    }
    
    // MARK: - Actions
    //    @objc private func pickerOpenAction(_ sender: UIButton?) {
    //        dummyTextField.inputView = pickerView
    //        dummyTextField.inputAccessoryView = pickerToolBar
    //        dummyTextField.becomeFirstResponder()
    //    }
    @objc private func pickerOpenAction(_ sender: UIButton?) {
        dummyTextField.inputView = pickerView
        dummyTextField.inputAccessoryView = pickerToolBar
        dummyTextField.becomeFirstResponder()
        
        //            // Ensure the search bar is ready for input
        //            DispatchQueue.main.async {
        //                self.searchBar.becomeFirstResponder()
        //            }
    }
    
    @objc private func pickerCloseWithoutAction() {
        dummyTextField.resignFirstResponder()
    }
    
    @objc private func pickerCloseAction(_ sender: UIBarButtonItem?) {
        countryNameLabel.textColor = .white
        dummyTextField.resignFirstResponder()
        if let selectedRow = pickerView.selectedRow(inComponent: 0) as Int?, selectedRow < filteredPickerViewData.count {
            let selectedPickerValue = self.filteredPickerViewData[selectedRow]
            self.countryNameLabel.text = "\(selectedPickerValue.flag ?? "") +\(selectedPickerValue.phoneExtensionCode ?? "")"
            self.delegate?.didSelectCountry(countryPhoneExtension: selectedPickerValue.phoneExtensionCode ?? "")
        }
    }
}

// MARK: - UIPickerView Extension
extension CountryCodeSelectionView: UIPickerViewDataSource, UIPickerViewDelegate {
    // MARK: DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.filteredPickerViewData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let country = self.filteredPickerViewData[row]
        return "\(country.flag ?? "") \(country.name ?? "") (+\(country.phoneExtensionCode ?? ""))"
    }
    
    //MARK: Delegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is now empty as we handle the selection in pickerCloseAction
    }
}

// MARK: - UISearchBarDelegate Extension
extension CountryCodeSelectionView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredPickerViewData = pickerViewData
        } else {
            filteredPickerViewData = pickerViewData.filter { country in
                return country.name?.lowercased().contains(searchText.lowercased()) ?? false ||
                country.phoneExtensionCode?.contains(searchText) ?? false
            }
        }
        pickerView.reloadAllComponents()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            guard searchText.isEmpty else { return }
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
