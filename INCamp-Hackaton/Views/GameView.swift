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
    @State private var roundStarted: Bool = false // New flag to track the start of each round
    
    // Animation states
    @State private var scaleEffect: CGFloat = 1.0
    @State private var turnIndicatorOpacity: Double = 1.0
    @State private var shakePowerUp: Bool = false
    @State private var winLineHighlighted: [Position] = []

    
    let primaryColor = Color(hex: "#FFC312")
    
    var body: some View {
        VStack {
            // Custom Back Button
            BackButtonView(primaryColor: primaryColor)
            
            // Health Display
            HealthDisplayView(gameMode: gameMode, firstPlayerHealth: firstPlayerHealth, secondPlayerHealth: secondPlayerHealth, primaryColor: primaryColor)
                .animation(.easeInOut, value: firstPlayerHealth)
                .animation(.easeInOut, value: secondPlayerHealth)
            
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
            .animation(.easeInOut, value: gameOver) // Fade-in for reset button when game is over
            
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
        .onChange(of: currentPlayer) { _, newPlayer in
            if gameMode == .computer && newPlayer == .computer && !gameOver {
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
            return true
        } else {
            return currentPlayer == .human
        }
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
    
    private func makeMoveWithAnimation(at position: Position) {
        withAnimation(.easeInOut(duration: 0.3)) {
            makeMove(at: position)
        }
    }

    private func makeMove(at position: Position) {
        guard board[position.row][position.col] == .none && !gameOver else { return }
        
        // Ensure it's the player's turn in computer mode
        if gameMode == .computer && currentPlayer != .human {
            return
        }
        
        let movingPlayer = currentPlayer
        board[position.row][position.col] = movingPlayer
        
        if let powerUp = powerSquares[position] {
            applyPowerUp(powerUp, at: position)
            powerSquares.removeValue(forKey: position)
        }
        
        if checkWin(for: movingPlayer) {
            handleWin(for: movingPlayer)
        } else if isBoardFull() {
            handleDraw()
        } else {
            switchTurns()
        }
    }
    
    private func isBoardFull() -> Bool {
        return !board.contains { $0.contains(.none) }
    }
    
    private func animateWinLine(for player: Player) {
        withAnimation(.linear(duration: 1.0)) {
            // Trigger any animations for highlighting the win
        }
    }
    
    
    private func shakePowerUpEffect() {
        withAnimation(Animation.default.repeatCount(3, autoreverses: true)) {
            shakePowerUp = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shakePowerUp = false
        }
    }
    
    private func switchTurns() {
        if gameMode == .pvp {
            currentPlayer = (currentPlayer == .first) ? .second : .first
        } else {
            if currentPlayer == .human {
                currentPlayer = .computer
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    makeComputerMove()
                }
            } else {
                currentPlayer = .human
            }
        }
    }
    
    private func makeComputerMove() {
        guard currentPlayer == .computer && !gameOver else { return }
        
        // Get available positions
        var availablePositions = [(row: Int, col: Int)]()
        for row in 0..<3 {
            for col in 0..<3 {
                if board[row][col] == .none {
                    availablePositions.append((row, col))
                }
            }
        }
        
        // Make the move
        if let winningMove = findBestMove(for: .computer) {
            board[winningMove.row][winningMove.col] = .computer
            
            if checkWin(for: .computer) {
                handleWin(for: .computer)
            } else {
                switchTurns()
            }
        } else if let blockingMove = findBestMove(for: .human) {
            board[blockingMove.row][blockingMove.col] = .computer
            
            if checkWin(for: .computer) {
                handleWin(for: .computer)
            } else {
                switchTurns()
            }
        } else if let randomPosition = availablePositions.randomElement() {
            board[randomPosition.row][randomPosition.col] = .computer
            
            if checkWin(for: .computer) {
                handleWin(for: .computer)
            } else if isBoardFull() {
                handleDraw()
            } else {
                switchTurns()
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
            alertMessage = "Wild Card: Place an extra mark!"
            showAlert = true
            wildCardFirstMarkPosition = position
            withAnimation(.spring()) {
                        wildCardFirstMarkPosition = position
                    }
            
        case .steal:
            // Capture an opponent’s mark
            for row in 0..<3 {
                for col in 0..<3 {
                    if board[row][col] == (currentPlayer == .human ? .computer : .human) {
                        board[row][col] = currentPlayer
                        withAnimation(.easeInOut(duration: 0.5)) {
                                                board[row][col] = currentPlayer
                                            }
                        return
                    }
                }
            }
            
        case .reverse:
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
    
    private func resetBoard() {
        board = Array(repeating: Array(repeating: .none, count: 3), count: 3)
        setupPowerSquares()
        
        if gameMode == .computer {
            currentPlayer = .human
        } else {
            currentPlayer = .first
        }
        
        wildCardFirstMarkPosition = nil
        gameOver = false
    }
    
    private func resetGame() {
        firstPlayerHealth = 3
        secondPlayerHealth = 3
        gameOver = false
        alertMessage = ""
        resetBoard()
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
