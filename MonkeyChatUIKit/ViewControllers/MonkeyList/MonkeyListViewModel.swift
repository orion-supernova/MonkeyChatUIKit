//
//  MonkeyListViewModel.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 14.03.2022.
//

import Foundation
import Firebase

final class MonkeyListViewModel {

    var friends = [User]()

    func fetchFriends(completion:  (() -> Void)? = nil ) {
        guard let userID = AppGlobal.shared.userID else { return }
        COLLECTION_USERS.document(userID).collection("chatRooms").document(userID).collection("friends").getDocuments { snapshot, error in
            guard error == nil else { print(error!.localizedDescription); return }
            guard let documents = snapshot?.documents else { return }

            self.friends = documents.compactMap({ try? $0.data(as: User.self)  })
            print("ChatRooms fetched successfully")
            completion?()
        }
    }

    func sendFriendRequest (completion:  (() -> Void)? = nil ) {
        guard let userID = AppGlobal.shared.userID else { return }
        COLLECTION_USERS.document(userID).collection("chatRooms").document(userID).collection("friends").getDocuments { snapshot, error in
            guard error == nil else { print(error!.localizedDescription); return }
            guard let documents = snapshot?.documents else { return }

            self.friends = documents.compactMap({ try? $0.data(as: User.self)  })
            print("ChatRooms fetched successfully")
            completion?()
        }
    }
}
