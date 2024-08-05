//
//  User.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import Firebase
import FirebaseFirestore

struct User: Identifiable, Decodable {
    var username: String
    @DocumentID var id: String?
    var uid: String?
    var chatRooms = [String]()
}
