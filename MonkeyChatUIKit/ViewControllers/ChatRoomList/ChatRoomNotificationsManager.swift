//
//  RoomNotificationsManager.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 22.02.2022.
//

import Foundation

class ChatRoomNotificationsManager {
    static let shared: ChatRoomNotificationsManager = {
        return ChatRoomNotificationsManager()
    }()

    // MARK: - Stored Properties
    var registeredRooms = [""]
    let defaults = UserDefaults.standard

    func getRooms() {
        let array = defaults.stringArray(forKey: "registeredRooms") ?? [String]()
    }

    func addRoom() {
        //
    }

    func removeRoom() {
        //
    }
}
