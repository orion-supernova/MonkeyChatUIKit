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

    // MARK: - Lifecycle

    // MARK: - Functions
    func subscribeForNewMessages(showAlert: Bool) {
        Messaging.messaging().subscribe(toTopic: "newMessages") { [weak self] error in
            guard error == nil else { return }
            self?.defaults.setValue(true, forKey: "isSubscribedForPushNotifications")
            if showAlert {
                AlertHelper.alertMessage(title: "Success", message: "You will be notified when a message received.", okButtonText: "OK")
            }
        }
    }

    func unsubscribeForNewMessages() {
        Messaging.messaging().unsubscribe(fromTopic: "newMessage") { [weak self] error in
            guard error == nil else { return }
            self?.defaults.setValue(false, forKey: "isSubscribedForPushNotifications")
            AlertHelper.alertMessage(title: "Success", message: "You won't get push notifications from now on.", okButtonText: "OK")
        }
    }


}
