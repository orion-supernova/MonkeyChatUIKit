//
//  AccountViewModel.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 24.01.2023.
//

import Foundation

final class AccountViewModel {

    // MARK: - Lifecycle
    deinit { print("DEBUG: --- DEINIT AccountViewModel") }

    typealias simpleCompletion = (Result<Any?, Error>) -> Void

    // MARK: - Public Methods
    func startDeleteUserAccount(completion: @escaping simpleCompletion) {
        LottieHUD.shared.show()
        let group = DispatchGroup()
        var chatRoomsArray = [String]()
        COLLECTION_USERS.document(AppGlobal.shared.userID ?? "").collection("chatRooms").getDocuments { chatRoomSnapshot, error in
            guard let chatRoomSnapshot = chatRoomSnapshot else { return }
            let documents = chatRoomSnapshot.documents
            if documents.isEmpty {
                self.removeUserAndLogout(completion: completion)
                return
            }
            for document in documents {
                chatRoomsArray.append(document.documentID)
            }
            group.enter()
            for roomID in chatRoomsArray {
                let room = COLLECTION_CHATROOMS.document(roomID)
                room.collection("userIDs").document(AppGlobal.shared.userID ?? "").delete()
                room.collection("userIDs").getDocuments(completion: { snapshot, error in
                    guard let snapshot = snapshot else { return }
                    if snapshot.documents.isEmpty {
                        room.delete()
                    }
                    group.leave()
                })
            }
            group.notify(queue: .global()) {
                COLLECTION_USERS.document(AppGlobal.shared.userID ?? "").collection("chatRooms").getDocuments { snapshot, error in
                    guard let snapshot = snapshot else { return }
                    snapshot.documents.forEach({ $0.reference.delete() })

                    COLLECTION_USERS.document(AppGlobal.shared.userID ?? "").delete { error in
                        guard error == nil else { return }
                        self.removeUserAndLogout(completion: completion)
                        return
                    }
                }
            }
        }
    }

    func removeUserAndLogout(completion: @escaping simpleCompletion) {
        AuthManager.shared.deleteUser { error in
            LottieHUD.shared.dismiss()
            if let error {
                completion(.failure(error))
                return
            }
            completion(.success(nil))
        }
    }
}
