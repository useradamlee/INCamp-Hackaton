//
//  Player.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

enum Player {
    case none, first, second, human, computer

    var symbol: String {
        switch self {
        case .none: return ""
        case .first, .human: return "X"
        case .second, .computer: return "O"
        }
    }

    var displayName: String {
        switch self {
        case .none: return "None"
        case .first: return "Player 1"
        case .second: return "Player 2"
        case .human: return "Player 1"
        case .computer: return "Computer"
        }
    }
}
