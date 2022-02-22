//
//  SettingsViewModel.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 19.02.2022.
//

import Foundation
import FirebaseMessaging

class SettingsViewModel {

    // MARK: - Stored Properties
    let defaults = UserDefaults.standard
    let fcmToken = AppGlobal.shared.fcmToken

    // MARK: - Lifecycle

    // MARK: - Functions
    func subscribeForNewMessages(showAlert: Bool, chatRoomID: String) {

        Messaging.messaging().subscribe(toTopic: chatRoomID) { [weak self] error in
            guard error == nil else { return }
            self?.defaults.setValue(true, forKey: "isSubscribedForPushNotifications")
            if showAlert {
                AlertHelper.alertMessage(title: "Success", message: "You will be notified when a message received.", okButtonText: "OK")
            }
        }
    }

    func unsubscribeForNewMessages(chatRoomID: String) {
        Messaging.messaging().unsubscribe(fromTopic: chatRoomID) { [weak self] error in
            guard error == nil else { return }
            self?.defaults.setValue(false, forKey: "isSubscribedForPushNotifications")
        }
    }

    func changeUsername(username: String) {
        if username == "" {
            AlertHelper.alertMessage(title: "Error", message: "Username can not be empty.", okButtonText: "OK")
        } else {
            AlertHelper.alertMessage(title: "In Progress", message: "Your username will be \(username), when I fix this :)", okButtonText: "oke")
        }
    }


}
