//
//  ChatRoom.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import Firebase
import FirebaseFirestoreSwift

struct ChatRoom: Identifiable, Decodable {
    @DocumentID var id: String?
    var name: String?
    var password: String?
    let timestamp: Timestamp
    var roomCode: UUID?
}
