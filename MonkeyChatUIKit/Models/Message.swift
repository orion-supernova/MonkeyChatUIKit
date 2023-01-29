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
    let message: String
    var profileImageURL: String?
    let timestamp: Timestamp
    var senderName: String?
    var senderUID: String?
    let chatRoomID: String?

    var timestampString: String? {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en")
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .brief
        formatter.calendar = calendar
        return formatter.string(from: timestamp.dateValue(), to: Date()) ?? ""
    }

}
