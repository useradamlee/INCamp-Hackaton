//
//  PowerUp.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

enum PowerUp: CaseIterable {
    case wildCard, steal, reverse
    
    var description: String {
        switch self {
        case .wildCard: return "Wild Card"
        case .steal: return "Steal"
        case .reverse: return "Reverse"
        }
    }
}
