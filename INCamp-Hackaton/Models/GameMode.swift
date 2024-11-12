//
//  GameMode.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

enum GameMode {
    case pvp, computer
    
    var description: String {
        switch self {
        case .pvp: return "Player vs Player"
        case .computer: return "Player vs Computer"
        }
    }
}
