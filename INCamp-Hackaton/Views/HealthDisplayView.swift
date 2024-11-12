//
//  HealthDisplayView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct HealthDisplayView: View {
    let gameMode: GameMode
    let firstPlayerHealth: Int
    let secondPlayerHealth: Int
    let primaryColor: Color

    var body: some View {
        HStack {
            HealthView(player: Player.first.displayName, health: firstPlayerHealth, color: primaryColor)
            Spacer()
            HealthView(player: gameMode == .pvp ? Player.second.displayName : "Computer",
                       health: secondPlayerHealth, color: primaryColor)
        }
        .padding([.leading, .trailing])
    }
}


#Preview {
    HealthDisplayView(
        gameMode: .pvp, // Player vs Player mode for testing
        firstPlayerHealth: 3, // Starting health for player 1
        secondPlayerHealth: 3, // Starting health for player 2
        primaryColor: Color.blue // A sample color for testing
    )
}

