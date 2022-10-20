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
    var fcmToken: String? {
        get {
            return UserDefaults.standard.value(forKey: "fcmToken") as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "fcmToken")
        }
    }
    var eulaConfirmed: Bool? {
        get {
            return UserDefaults.standard.value(forKey: "eulaConfirmed") as? Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "eulaConfirmed")
        }
    }

    enum CurrentPage {
        case monkeyList
        case settings
        case chatRoom
        case roomSettings
    }

    var currentPage: CurrentPage = .monkeyList

    var lastEnteredChatRoomID = ""
}
