//
//  GameView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct GameView: View {
    let gameMode: GameMode
    let difficulty: Difficulty
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
    @State private var roundStarted: Bool = false
    @State private var isWildCardActive: Bool = false
    @State private var wildCardPlayer: Player? = nil
    
    // Animation states
    @State private var scaleEffect: CGFloat = 1.0
    @State private var turnIndicatorOpacity: Double = 1.0
    @State private var shakePowerUp: Bool = false
    @State private var winLineHighlighted: [Position] = []
    @State private var showingQuitAlert = false
    @State private var navigateToHome = false

    
    let primaryColor = Color(hex: "#FFC312")
    
    var body: some View {
        VStack {
            // Custom Back Button
//            BackButtonView(primaryColor: primaryColor, showingAlert: $showingQuitAlert, navigateToHome: $navigateToHome)
//                .alert(isPresented: $showingQuitAlert) {
//                    Alert(
//                        title: Text("Quit Game"),
//                        message: Text("Are you sure you want to quit the game?"),
//                        primaryButton: .destructive(Text("Quit")) {
//                            navigateToHome = true
//                        },
//                        secondaryButton: .cancel()
//                    )
//                }
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
        .navigationDestination(isPresented: $navigateToHome) {
            HomeView()
        }
//        .navigationBarBackButtonHidden(true)  // Hide default back button
    }

    
    // Game Logic Functions
    // Update the canMakeMove function
    private func canMakeMove(gameMode: GameMode, currentPlayer: Player) -> Bool {
        if isWildCardActive {
            return true  // Allow the Wild Card move regardless of whose turn it is
        }
        
        if gameMode == .pvp {
            return true
        } else {
            return currentPlayer == .human
        }
    }

    
    private func setupGame() {
        resetBoard()
        // Move setupPowerSquares() after board reset to ensure proper initialization
        setupPowerSquares()
        
        if gameMode == .pvp {
            currentPlayer = .first
            // Add this line to ensure power-ups are ready for the first turn
            powerSquares = setupInitialPowerSquares()
        } else {
            currentPlayer = .human
        }
    }

    // Add this new function to properly initialize power squares
    private func setupInitialPowerSquares() -> [Position: PowerUp] {
        var squares = [Position: PowerUp]()
        let numberOfPowerUps = Int.random(in: 1...2)
        
        // Create array of all possible positions
        var availablePositions = [Position]()
        for row in 0..<3 {
            for col in 0..<3 {
                availablePositions.append(Position(row: row, col: col))
            }
        }
        
        // Randomly assign power-ups
        for _ in 0..<numberOfPowerUps {
            if let randomPosition = availablePositions.randomElement(),
               let randomIndex = availablePositions.firstIndex(of: randomPosition) {
                squares[randomPosition] = PowerUp.allCases.randomElement()
                availablePositions.remove(at: randomIndex)
            }
        }
        
        return squares
    }
    
    private func makeMoveWithAnimation(at position: Position) {
        withAnimation(.easeInOut(duration: 0.3)) {
            makeMove(at: position)
        }
    }

    private func makeMove(at position: Position) {
        // Check if the square is already occupied or if game is over
        guard board[position.row][position.col] == .none && !gameOver else { return }
        
        // Make the move
        withAnimation(.easeInOut(duration: 0.3)) {
            board[position.row][position.col] = currentPlayer
        }
        
        // Check if the move was on a power-up square
        if let powerUp = powerSquares[position] {
            applyPowerUp(powerUp, at: position)
            powerSquares.removeValue(forKey: position)
            // Don't switch turns here - it will be handled in applyPowerUp when the power-up effect is complete
            return
        }
        
        // If no power-up, check win condition and switch turns normally
        if checkWin(for: currentPlayer) {
            handleWin(for: currentPlayer)
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
        
        // Modify this part to adjust computer move difficulty based on the difficulty setting
        if difficulty == .easy {
            if let randomPosition = availablePositions.randomElement() {
                board[randomPosition.row][randomPosition.col] = .computer
            }
        } else if difficulty == .medium {
            if let winningMove = findBestMove(for: .computer) {
                board[winningMove.row][winningMove.col] = .computer
            } else if let blockingMove = findBestMove(for: .human) {
                board[blockingMove.row][blockingMove.col] = .computer
            } else if let randomPosition = availablePositions.randomElement() {
                board[randomPosition.row][randomPosition.col] = .computer
            }
        } else if difficulty == .hard {
            if let bestMove = findBestMove(for: .computer) {
                board[bestMove.row][bestMove.col] = .computer
            }
        }
        
        if checkWin(for: .computer) {
            handleWin(for: .computer)
        } else if isBoardFull() {
            handleDraw()
        } else {
            switchTurns()
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
            isWildCardActive = true
            wildCardPlayer = currentPlayer
            alertMessage = "Wild Card: Place an extra mark!"
            showAlert = true
            
        case .steal:
            var stoleAMark = false
            for row in 0..<3 {
                for col in 0..<3 {
                    // Fix the opponent determination based on game mode
                    let opponent: Player
                    if gameMode == .computer {
                        opponent = currentPlayer == .human ? .computer : .human
                    } else {
                        opponent = currentPlayer == .first ? .second : .first
                    }
                    
                    if board[row][col] == opponent {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            board[row][col] = currentPlayer
                        }
                        stoleAMark = true
                        break
                    }
                }
                if stoleAMark { break }
            }
            if checkWin(for: currentPlayer) {
                handleWin(for: currentPlayer)
            } else {
                switchTurns()
            }
            
        case .reverse:
            board[position.row][position.col] = .none
            alertMessage = "Reverse: Your last move was undone!"
            showAlert = true
            switchTurns()
        }
    }
    
    // Add this helper function to complete the Wild Card move
    private func completeWildCardMove(at position: Position) {
        guard isWildCardActive && board[position.row][position.col] == .none else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            board[position.row][position.col] = wildCardPlayer ?? currentPlayer
        }
        
        isWildCardActive = false
        
        // Check win condition after the second mark is placed
        if checkWin(for: wildCardPlayer ?? currentPlayer) {
            handleWin(for: wildCardPlayer ?? currentPlayer)
        } else if isBoardFull() {
            handleDraw()
        } else {
            // Only switch turns after the Wild Card effect is complete
            switchTurns()
        }
        
        wildCardPlayer = nil
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
        isWildCardActive = false
        wildCardPlayer = nil
        
        if gameMode == .computer {
            currentPlayer = .human
        } else {
            currentPlayer = .first
        }
        
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
    GameView(gameMode: .pvp, difficulty: .medium)
}
