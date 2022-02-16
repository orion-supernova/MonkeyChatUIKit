//
//  User.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import FirebaseFirestoreSwift

struct User: Identifiable, Decodable {
    var username: String
    @DocumentID var id: String?
}
