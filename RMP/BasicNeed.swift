//
//  BasicNeed.swift
//  RMP
//
//  Created by David Klopp on 02.01.20.
//  Copyright © 2020 David Klopp. All rights reserved.
//

import Foundation


extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}

enum BasicNeed: String, CaseIterable {
    case ACCEPTANCE
    case CURIOSITY
    case EATING
    case FAMILY
    case HONOR
    case IDEALISM
    case INDEPENDENCE
    case ORDER
    case PHYSICAL_ACTIVITY
    case POWER
    case ROMANCE
    case SAVING
    case SOCIAL_CONTACT
    case STATUS
    case TRANQUILITY
    case VENGEANCE

    static var asArray: [BasicNeed] {return self.allCases}

    func asInt() -> Int {
        return BasicNeed.asArray.firstIndex(of: self)!
    }

    func questionKeys(strongDesire: Bool) -> [String] {
        let key = strongDesire ? "STRONG" : "WEAK"
        return [self.rawValue + "_QUESTION_" + key + String(1),
                self.rawValue + "_QUESTION_" + key + String(2),
                self.rawValue + "_QUESTION_" + key + String(3)]
    }
}
