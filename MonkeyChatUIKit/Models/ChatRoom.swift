//
//  ChatRoom.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import Firebase
import FirebaseFirestore

struct ChatRoom: Identifiable, Decodable {
    @DocumentID var id: String?
    var name: String?
    var password: String?
    let timestamp: Timestamp
    var roomCode: UUID?
    var messages: [Message]?
    var imageURL: String?
    var lastMessageTimestamp: Timestamp?
}
