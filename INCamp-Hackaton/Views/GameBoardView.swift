//
//  GameBoardView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct GameBoardView: View {
    let board: [[Player]]
    let powerSquares: [Position: PowerUp]
    let primaryColor: Color
    let gameMode: GameMode
    let currentPlayer: Player
    let canMakeMove: Bool
    let makeMove: (Position) -> Void

    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<3) { row in
                HStack(spacing: 8) {
                    ForEach(0..<3) { col in
                        GameSquare(
                            symbol: board[row][col].symbol,
                            isPowerSquare: powerSquares.keys.contains(Position(row: row, col: col)),
                            action: {
                                // Allow move if it's the current player's turn and the square is empty
                                if canMakeMove && board[row][col] == .none {
                                    makeMove(Position(row: row, col: col))
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    GameBoardView(
        board: Array(repeating: Array(repeating: Player.none, count: 3), count: 3), // Sample 3x3 grid
        powerSquares: [:], // No power squares for testing
        primaryColor: Color.blue, // Just a test color
        gameMode: .pvp, // Player vs Player mode
        currentPlayer: .first, // Starting with Player 1
        canMakeMove: true, // Allow moves for preview
        makeMove: { _ in } // No-op for preview
    )
}
