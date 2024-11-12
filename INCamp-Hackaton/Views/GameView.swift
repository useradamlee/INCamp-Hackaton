//
//  GameView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct GameView: View {
    let gameMode: GameMode
    @Environment(\.presentationMode) var presentationMode
    
    @State private var board: [[Player]] = Array(repeating: Array(repeating: .none, count: 3), count: 3)
    @State private var currentPlayer: Player = .first
    @State private var firstPlayerHealth: Int = 3
    @State private var secondPlayerHealth: Int = 3
    @State private var powerSquares: [Position: PowerUp] = [:]
    @State private var gameOver: Bool = false
    @State private var wildCardFirstMarkPosition: Position?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var lastOpponentMove: Position? = nil

    
    let primaryColor = Color(hex: "#FFC312")
    
    var body: some View {
        VStack {
            // Custom Back Button
            BackButtonView(primaryColor: primaryColor)
            
            // Health Display
            HealthDisplayView(gameMode: gameMode, firstPlayerHealth: firstPlayerHealth, secondPlayerHealth: secondPlayerHealth, primaryColor: primaryColor)
            
            // Current Player Indicator
            CurrentPlayerIndicatorView(currentPlayer: currentPlayer)
            
            GameBoardView(
                board: board,
                powerSquares: powerSquares,
                primaryColor: primaryColor,
                gameMode: gameMode,
                currentPlayer: currentPlayer,
                canMakeMove: canMakeMove(gameMode: gameMode, currentPlayer: currentPlayer), // Call the function to get the boolean value
                makeMove: makeMove
            )
            .disabled(gameOver) // Disable board when game is over


            
            // Reset Button
            Button(action: resetGame) {
                Text("New Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(primaryColor)
                    .cornerRadius(10)
            }
            .padding()
            .shadow(radius: 3)
            
            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if gameOver {
                        resetGame()
                    }
                }
            )
        }
        .onAppear(perform: setupGame)
        .onChange(of: currentPlayer) {
            if gameMode == .computer && currentPlayer == .second && !gameOver {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    makeComputerMove()
                }
            }
        }
        .navigationBarBackButtonHidden(true)  // Hide default back button
    }

    
    // Game Logic Functions
    private func canMakeMove(gameMode: GameMode, currentPlayer: Player) -> Bool {
        if gameMode == .pvp {
            return true // Player vs Player: anyone can make a move
        } else {
            // Player vs Computer: allow human (Player 1) to make a move, then make the computer move
            if currentPlayer == .first {
                return true
            } else if currentPlayer == .second && !gameOver {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    makeComputerMove()
                }
                return false // Don't allow the computer to wait for a press, let it move automatically
            }
        }
        return false
    }

    
    private func setupGame() {
        resetBoard()
        setupPowerSquares()
    }
    
    private func makeMove(at position: Position) {
        guard board[position.row][position.col] == .none && !gameOver else { return }
        
        // Make the move for the current player
        board[position.row][position.col] = currentPlayer
        
        // Apply the power-up if available
        if let powerUp = powerSquares[position] {
            if powerUp == .wildCard {
                // Activate Wild Card: Let the player choose an extra square
                alertMessage = "Wild Card: Select another square to place an extra mark!"
                showAlert = true
                // Store the position of the first mark
                wildCardFirstMarkPosition = position
            } else {
                // For other power-ups (steal, reverse)
                applyPowerUp(powerUp, at: position)
                powerSquares.removeValue(forKey: position) // Remove the power-up from the board after it is used
            }
        }

        // Check for win or draw
        if checkWin(for: currentPlayer) {
            handleWin(for: currentPlayer)
        } else if isBoardFull() {
            handleDraw()
        } else {
            // Switch turns based on game mode
            if gameMode == .pvp {
                currentPlayer = (currentPlayer == .first) ? .second : .first
            } else {
                currentPlayer = (currentPlayer == .first) ? .second : .first
                if currentPlayer == .second {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        makeComputerMove() // Let the computer make its move immediately
                    }
                }
            }
        }
    }



    
    private func makeComputerMove() {
        guard currentPlayer == .computer && !gameOver else { return }
        
        // Try to find winning move
        if let winningMove = findBestMove(for: .computer) {
            makeMove(at: winningMove)
            return
        }
        
        // Try to block player's winning move
        if let blockingMove = findBestMove(for: .human) {
            makeMove(at: blockingMove)
            return
        }
        
        // Make random move if no strategic moves available
        var availablePositions = [Position]()
        for row in 0..<3 {
            for col in 0..<3 {
                if board[row][col] == .none {
                    availablePositions.append(Position(row: row, col: col))
                }
            }
        }
        
        if let randomPosition = availablePositions.randomElement() {
            makeMove(at: randomPosition)
        }
    }
    
    
    private func findBestMove(for player: Player) -> Position? {
        // Check for winning moves
        for row in 0..<3 {
            for col in 0..<3 {
                let position = Position(row: row, col: col)
                if board[row][col] == .none {
                    // Try move
                    board[row][col] = player
                    if checkWin(for: player) {
                        // Undo move and return position if it's a winning move
                        board[row][col] = .none
                        return position
                    }
                    // Undo move if not winning
                    board[row][col] = .none
                }
            }
        }
        return nil
    }
    
    private func applyPowerUp(_ powerUp: PowerUp, at position: Position) {
        switch powerUp {
        case .wildCard:
            
            // Place an extra mark anywhere
            alertMessage = "Wild Card: Place an extra mark!"
            showAlert = true
            
        case .steal:
            // Steal opponent's mark
            for row in 0..<3 {
                for col in 0..<3 {
                    if board[row][col] == (currentPlayer == .human ? .computer : .human) {
                        board[row][col] = currentPlayer
                        return
                    }
                }
            }
        case .reverse:
            // Reverse the last move
            board[position.row][position.col] = .none
            alertMessage = "Reverse: Your opponent's last move was undone!"
            showAlert = true
        }
    }
    
    // Inside handleWin(for: Player)
    private func handleWin(for player: Player) {
        if player == .first {
            secondPlayerHealth -= 1
            alertMessage = secondPlayerHealth > 0 ? "Player 1 won this round!" : "Player 1 won the game!"
        } else {
            firstPlayerHealth -= 1
            alertMessage = firstPlayerHealth > 0 ? "Player 2 won this round!" : "Player 2 won the game!"
        }
        
        gameOver = firstPlayerHealth == 0 || secondPlayerHealth == 0
        showAlert = true
        
        if !gameOver {
            resetBoard()
        }
    }
    
    private func handleDraw() {
        alertMessage = "It's a draw!"
        showAlert = true
        resetBoard()
    }
    
    private func checkWin(for player: Player) -> Bool {
        // Check rows and columns
        for i in 0..<3 {
            if board[i].allSatisfy({ $0 == player }) ||
                board.map({ $0[i] }).allSatisfy({ $0 == player }) {
                return true
            }
        }
        
        // Check diagonals
        if (board[0][0] == player && board[1][1] == player && board[2][2] == player) ||
            (board[0][2] == player && board[1][1] == player && board[2][0] == player) {
            return true
        }
        
        return false
    }
    
    private func isBoardFull() -> Bool {
        return !board.contains { $0.contains(.none) }
    }
    
    private func resetGame() {
        // Reset health for both players
        firstPlayerHealth = 3
        secondPlayerHealth = 3
        gameOver = false
        alertMessage = ""
        
        // Reset the board and current player based on game mode
        resetBoard()
        currentPlayer = .first // Always start with the first player
        
        // If the game mode is player vs. computer, set the current player to start with Player 1
        if gameMode == .computer {
            currentPlayer = .first
        } else {
            currentPlayer = .first
        }
    }
    
    private func resetBoard() {
        board = Array(repeating: Array(repeating: .none, count: 3), count: 3)
        currentPlayer = .first
        setupPowerSquares()
    }

    
    private func setupPowerSquares() {
        powerSquares.removeAll()
        // Add 1-2 random power-ups
        let numberOfPowerUps = Int.random(in: 1...2)
        for _ in 0..<numberOfPowerUps {
            let position = Position(row: Int.random(in: 0..<3), col: Int.random(in: 0..<3))
            if board[position.row][position.col] == .none {
                powerSquares[position] = PowerUp.allCases.randomElement()!
            }
        }
    }
}

#Preview {
    GameView(gameMode: .pvp)
}
