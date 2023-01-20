//
//  AlertHelper.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit

class AlertHelper {

    static func alertMessage(title: String, message: String, okButtonText: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonText, style: .default) { (action: UIAlertAction) in
        }
        alertVC.addAction(okAction)
        alertVC.view.tintColor = .systemPink

        let viewController = UIApplication.shared.windows.first!.rootViewController!
        viewController.present(alertVC, animated: true, completion: nil)
    }

    static func alertMessage(viewController: UIViewController, title: String, message: String, okButtonText: String, completion: @escaping () -> Void ) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: okButtonText, style: .default) { (action: UIAlertAction) in
            completion()
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        alertVC.view.tintColor = .systemPink

        viewController.present(alertVC, animated: true, completion: nil)
    }

    static func alertMessage(viewController: UIViewController, title: String, message: String, completion: @escaping () -> Void ) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in
            completion()
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        alertVC.view.tintColor = .systemPink

        viewController.present(alertVC, animated: true, completion: nil)
    }

    static func simpleAlertMessage(viewController: UIViewController, title: String, message: String, completion: (() -> Void)? = nil) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in
            completion?()
        }
        alertVC.addAction(okAction)
        alertVC.view.tintColor = .systemPink
        viewController.present(alertVC, animated: true, completion: nil)
    }
}
