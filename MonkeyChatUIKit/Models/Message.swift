//
//  Message.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import Firebase
import FirebaseFirestoreSwift

struct Message: Identifiable, Decodable {

    @DocumentID var id: String?
    let username: String
    let profileImageURL: String?
    let timestamp: Timestamp
    let uid: String

    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: timestamp.dateValue(), to: Date()) ?? ""
    }

}
