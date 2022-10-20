//
//  PushNotificationSender.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 19.02.2022.
//

import UIKit

class PushNotificationSender {
    func sendPushNotification(to token: String, title: String, body: String, chatRoomID: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title,
                                                             "body" : body,
                                                             "sound" : "apns-sound.wav"],
                                           "data" : ["user" : AppGlobal.shared.userID,
                                                     "chatRoomID" : chatRoomID]
        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
