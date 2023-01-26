//
//  PushNotificationSender.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 19.02.2022.
//

import UIKit

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String, chatRoomID: String, chatRoomName: String, category: PushNotificationIdentifiers.Category) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        var userID = ""
        var fcmToken = ""
        #if targetEnvironment(simulator)
        // Simulator
        userID = "##SimulatorDevice##"
        fcmToken = SensitiveData.fcmToken
        #else
        // Real Device
        userID = AppGlobal.shared.userID ?? ""
        fcmToken = AppGlobal.shared.fcmToken ?? ""
        #endif
        let paramString: [String : Any] = ["to": token,
                                           "notification": ["title": title,
                                                             "body": body,
                                                             "sound": "apns-sound.wav",
                                                             "priority": "high",
                                                             "content_available": true,
                                                             "click_action": category.rawValue],
                                           "data": ["userID": userID,
                                                     "username": AppGlobal.shared.username,
                                                     "fcmToken": fcmToken,
                                                     "chatRoomID": chatRoomID,
                                                     "chatRoomName": chatRoomName]
        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("5", forHTTPHeaderField: "apns-priority")
        request.setValue("background", forHTTPHeaderField: "apns-push-type")
        request.setValue("key=\(SensitiveData.pushAuthKey)", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
