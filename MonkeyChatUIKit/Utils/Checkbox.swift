//
//  Checkbox.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 19.02.2022.
//

import UIKit

class NotificationsCheckBox: UIButton {
    // Images
    let checkedImage = UIImage(systemName: "bell")
    let uncheckedImage = UIImage(systemName: "bell.slash")

    // Bool property
    var isChecked: Bool = true {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: .normal)
                let viewmodel = SettingsViewModel()
                viewmodel.subscribeForNewMessages(showAlert: true)
            } else {
                self.setImage(uncheckedImage, for: .normal)
                let viewmodel = SettingsViewModel()
                viewmodel.unsubscribeForNewMessages()
            }
        }
    }

    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = true
        self.tintColor = .secondaryLabel
    }

    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}
