//
//  AuthManager.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 21.02.2022.
//

import Foundation
import FirebaseAuth

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
            completion(true)
        }
    }

    func signOut(completion: @escaping () -> Void) {
        try? Auth.auth().signOut()
        print("logout")
        completion()
    }
}
