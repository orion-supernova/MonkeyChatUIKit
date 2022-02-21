//
//  AppGlobal.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 21.02.2022.
//

import Foundation

class AppGlobal {
    static let shared: AppGlobal = {
        return AppGlobal()
    }()

    var username: String? {
        get {
            return UserDefaults.standard.value(forKey: "username") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "username")
        }
    }
    var userID: String? {
        get {
            return UserDefaults.standard.value(forKey: "userID") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userID")
        }
    }
}
