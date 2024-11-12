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
        .onChange(of: currentPlayer) { oldValue, newValue in
            // Only trigger computer move if it's explicitly switched to computer's turn
            if gameMode == .computer && newValue == .computer && !gameOver {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.currentPlayer == .computer && !self.gameOver {
                        self.makeComputerMove()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)  // Hide default back button
    }

    
    // Game Logic Functions
    private func canMakeMove(gameMode: GameMode, currentPlayer: Player) -> Bool {
        if gameMode == .pvp {
            return true
        } else {
            if currentPlayer == .human {
                return true
            } else if currentPlayer == .computer && !gameOver {
                makeComputerMove()
                return false
            }
        }
        return false
    }

    
    private func setupGame() {
        resetBoard()
        setupPowerSquares()
        
        if gameMode == .computer {
            currentPlayer = .human
        } else {
            currentPlayer = .first
        }
    }
    
    private func makeMove(at position: Position) {
        // Prevent moves during processing
        guard board[position.row][position.col] == .none && !gameOver else { return }
        
        // State tracking
        let currentGameMode = gameMode
        let movingPlayer = currentPlayer
        
        // Make the move
        board[position.row][position.col] = movingPlayer
        
        // Handle power-ups
        if let powerUp = powerSquares[position] {
            if powerUp == .wildCard {
                wildCardFirstMarkPosition = position
                alertMessage = "Wild Card: Select another square to place an extra mark!"
                showAlert = true
            } else {
                applyPowerUp(powerUp, at: position)
            }
            powerSquares.removeValue(forKey: position)
        }
        
        // Check game state
        if checkWin(for: movingPlayer) {
            DispatchQueue.main.async {
                self.handleWin(for: movingPlayer)
            }
        } else if isBoardFull() {
            DispatchQueue.main.async {
                self.handleDraw()
            }
        } else {
            // Switch turns with proper state management
            DispatchQueue.main.async {
                if currentGameMode == .pvp {
                    self.currentPlayer = (movingPlayer == .first) ? .second : .first
                } else {
                    if movingPlayer == .human {
                        self.currentPlayer = .computer
                        // Ensure computer move happens after state update
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.makeComputerMove()
                        }
                    } else {
                        self.currentPlayer = .human
                    }
                }
            }
        }
    }

    
    private func switchTurns() {
        if gameMode == .pvp {
            currentPlayer = (currentPlayer == .first) ? .second : .first
        } else {
            currentPlayer = (currentPlayer == .human) ? .computer : .human
            if currentPlayer == .computer {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    makeComputerMove()
                }
            }
        }
    }
    
    private func makeComputerMove() {
        // Prevent multiple computer moves
        guard currentPlayer == .computer && !gameOver else { return }
        
        // Add delay to prevent rapid moves
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let winningMove = self.findBestMove(for: .computer) {
                self.makeMove(at: winningMove)
            } else if let blockingMove = self.findBestMove(for: .human) {
                self.makeMove(at: blockingMove)
            } else {
                // Random move
                let availablePositions = self.getAvailablePositions()
                if let randomPosition = availablePositions.randomElement() {
                    self.makeMove(at: randomPosition)
                }
            }
        }
    }
    
    private func getAvailablePositions() -> [Position] {
        var positions = [Position]()
        for row in 0..<3 {
            for col in 0..<3 {
                if board[row][col] == .none {
                    positions.append(Position(row: row, col: col))
                }
            }
        }
        return positions
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
        DispatchQueue.main.async {
            if player == .first || player == .human {
                self.secondPlayerHealth = max(0, self.secondPlayerHealth - 1)
                self.alertMessage = self.secondPlayerHealth > 0 ? "Player 1 won this round!" : "Player 1 won the game!"
            } else {
                self.firstPlayerHealth = max(0, self.firstPlayerHealth - 1)
                self.alertMessage = self.firstPlayerHealth > 0 ? "\(player.displayName) won this round!" : "\(player.displayName) won the game!"
            }
            
            self.gameOver = self.firstPlayerHealth == 0 || self.secondPlayerHealth == 0
            self.showAlert = true
            
            if !self.gameOver {
                self.resetBoard()
            }
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
        
        // Reset the board and set initial player based on game mode
        resetBoard()
        
        // Set initial player based on game mode
        if gameMode == .computer {
            currentPlayer = .human  // Start with human player in PvC mode
        } else {
            currentPlayer = .first  // Start with Player 1 in PvP mode
        }
    }
    
    private func resetBoard() {
        // Reset the board
        board = Array(repeating: Array(repeating: .none, count: 3), count: 3)
        
        // Reset power squares
        setupPowerSquares()
        
        // Important: Reset to the correct starting player based on game mode
        if gameMode == .computer {
            currentPlayer = .human  // Always start with human in PvC mode
        } else {
            currentPlayer = .first  // Start with first player in PvP mode
        }
        
        // Reset any other game state
        wildCardFirstMarkPosition = nil
        gameOver = false
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
