//
//  Extensions.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 28.10.2022.
//

import UIKit

extension String {

    /// Replaces all the chars with asterisk for the given string.
    /// - Returns: Asterisks with the same string count.
    func replaceCharactersWithAsterisk() -> String {
        var temp = ""
        for _ in self {
            temp.append("*")
        }
        return temp
    }
}

extension UIViewController {
    /// Returns the viewController presented on the screen.
    var topController: UIViewController? {
        if let controller = self as? UINavigationController {
            return controller.topViewController?.topController
        } else if let controller = self as? UITabBarController {
            return controller.selectedViewController?.topController
        } else if let controller = presentedViewController {
            return controller.topController
        } else {
            return self
        }
    }
}
