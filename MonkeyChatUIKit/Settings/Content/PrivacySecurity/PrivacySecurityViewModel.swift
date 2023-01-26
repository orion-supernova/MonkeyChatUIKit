//
//  PrivacySecurityViewModel.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 26.01.2023.
//

import Foundation
import Firebase

final class PrivacySecurityViewModel {

    // MARK: - Enum
    enum webViewType {
        case privacySecurityTermsAndConditions
        case eula
    }

    deinit {
        print("PrivacySecurityViewModel deinit")
    }

    // MARK: - Public Properties
    var policyURLString: String?
    var eulaURLString: String?

    // MARK: - Public Methods
    func getWebURL(with type: webViewType) -> URL {
        switch type {
            case .privacySecurityTermsAndConditions:
                guard let url = URL(string: policyURLString ?? "") else { return URL(string: "https://walhallaa.com")! }
                return url
            case .eula:
                guard let url = URL(string: eulaURLString ?? "") else { return URL(string: "https://walhallaa.com")! }
                return url
        }
    }

    // MARK: - Private Methods
    func getWebLinks(completion: @escaping (Bool) -> Void) {
        COLLECTION_WEBLINKS.document("weblinks").getDocument { snapshot, error in
            guard error == nil else { return }
            guard let snapshot else { return }
            guard let dict = snapshot.data() else { return }
            self.policyURLString = dict["policy"] as? String
            self.eulaURLString   = dict["eula"] as? String
            completion(true)
        }
    }
}
