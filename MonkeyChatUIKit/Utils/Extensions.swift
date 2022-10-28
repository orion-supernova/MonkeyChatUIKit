//
//  Extensions.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 28.10.2022.
//

import Foundation

extension String {

    /// Replaces all the chars with asterisk for the given string.
    /// - Returns: Asterisks with the same string count.
    func replaceCharactersWithAsterisk() -> String {
        var temp = ""
        for _ in self {
            temp.append("*")
        }
        return temp
    }
}
