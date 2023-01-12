//
//  AuthManager.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 21.02.2022.
//

import Foundation
import FirebaseAuth
import Firebase

class AuthManager {
    static let shared = AuthManager()

    private var verificationID: String?

    func startAuth(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] id, error in
            guard let verificationID = id, error == nil else { completion(false); return }
            self?.verificationID = verificationID
            completion(true)
        }
    }

    func verifyCodeAndSignIn(smsCode: String, completion: @escaping (Bool) -> Void) {
        guard let verificationID = verificationID else { completion(false); return }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: smsCode)
        Auth.auth().signIn(with: credential) { result, error in
            guard result != nil, error == nil else { completion(false); return}
            AppGlobal.shared.userID = Auth.auth().currentUser?.uid
            guard let id = AppGlobal.shared.userID else { return }

            let data = ["username": "",
                        "uid": id]
            COLLECTION_USERS.document(id).setData(data) { error in
                print("Sucessfully uploaded user data!")
            }
            completion(true)
        }
    }

    func signOut(completion: @escaping () -> Void) {
        try? Auth.auth().signOut()
        print("logout")
        completion()
    }

    func deleteUser(completion: @escaping (Error?) -> Void) {
        Auth.auth().currentUser?.delete(completion: { error in
            if error != nil {
                completion(error)
                // Auth.auth().currentUser?.reauthenticate(with: <#T##AuthCredential#>)
            } else {
                completion(nil)
            }
        })
    }
}
