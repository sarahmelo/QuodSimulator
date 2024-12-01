//
//  Validators.swift
//  QuodSimulator
//
//  Created by ipmedia on 01/12/24.
//

import Foundation

class Validators {
    static func hasOnlyNumbers(text: String) -> Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: text))
    }
    
    static func isEmpty(text: String) -> Bool {
        return text.isEmpty;
    }
    
    static func findPhoneNumber(phoneNumber: Int, data: [Chip]) -> Chip? {
        return data.first(where: { $0.number == phoneNumber })
    }

}
