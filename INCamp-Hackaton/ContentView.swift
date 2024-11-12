//
//  ContentView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//
//
//import SwiftUI
//
//enum Player {
//    case none, human, computer
//    
//    var symbol: String {
//        switch self {
//        case .none: return ""
//        case .human: return "X"
//        case .computer: return "O"
//        }
//    }
//}
//
//struct ContentView: View {
//    @State private var board: [[Player]] = Array(repeating: Array(repeating: .none, count: 3), count: 3)
//    @State private var currentPlayer: Player = .human
//    @State private var humanHealth: Int = 3
//    @State private var computerHealth: Int = 3
//    @State private var gameMode: GameMode = .standard
//    @State private var powerSquares: [Position: PowerUp] = [:]
//    @State private var gameOver: Bool = false
//    @State private var winner: Player? = nil
//    @State private var showAlert: Bool = false
//    @State private var alertMessage: String = ""
//    
//    let primaryColor = Color(hex: "#FFC312")
//    let accentColor = Color.black // Using black for contrast against yellow
//    
//    var body: some View {
//        VStack {
//            Text("Tickle That Toe")
//                .font(.largeTitle)
//                .bold()
//                .foregroundColor(accentColor)
//                .padding()
//            
//            // Health Display with Iconsv
//            HStack {
//                HealthView(player: "Human", health: humanHealth, color: primaryColor)
//                Spacer()
//                HealthView(player: "Computer", health: computerHealth, color: primaryColor)
//            }
//            .padding([.leading, .trailing])
//            
//            // Current Player Indicator
//            Text("\(currentPlayer == .human ? "Your" : "Computer's") Turn")
//                .font(.headline)
//                .foregroundColor(accentColor)
//                .padding(.top)
//            
//            // Game Board
//            VStack(spacing: 8) {
//                ForEach(0..<3) { row in
//                    HStack(spacing: 8) {
//                        ForEach(0..<3) { col in
//                            GameSquare(
//                                symbol: board[row][col].symbol,
//                                isPowerSquare: powerSquares.keys.contains(Position(row: row, col: col)),
//                                primaryColor: primaryColor,
//                                action: {
//                                    if currentPlayer == .human {
//                                        makeMove(at: Position(row: row, col: col))
//                                    }
//                                }
//                            )
//                        }
//                    }
//                }
//            }
//            .padding()
//            .disabled(currentPlayer == .computer || gameOver)
//            
//            // Reset Button
//            Button(action: resetGame) {
//                Text("New Game")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(primaryColor)
//                    .cornerRadius(10)
//            }
//            .padding()
//            .shadow(radius: 3)
//            
//            Spacer()
//        }
//        .alert(isPresented: $showAlert) {
//            Alert(
//                title: Text(alertMessage),
//                dismissButton: .default(Text("OK")) {
//                    if gameOver {
//                        resetGame()
//                    }
//                }
//            )
//        }
//        .onAppear(perform: setupGame)
//        .onChange(of: currentPlayer) {
//            if currentPlayer == .computer && !gameOver {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    makeComputerMove()
//                }
//            }
//        }
//    }
//    
//    private func setupGame() {
//        resetBoard()
//        setupPowerSquares()
//    }
//    
//    private func makeMove(at position: Position) {
//        guard board[position.row][position.col] == .none && !gameOver else { return }
//        
//        // Make move
//        board[position.row][position.col] = currentPlayer
//        
//        // Apply power-up if available
//        if let powerUp = powerSquares[position] {
//            applyPowerUp(powerUp, at: position)
//            powerSquares.removeValue(forKey: position)
//        }
//        
//        // Check win condition
//        if checkWin(for: currentPlayer) {
//            handleWin(for: currentPlayer)
//        } else if isBoardFull() {
//            handleDraw()
//        } else {
//            // Switch turns
//            currentPlayer = (currentPlayer == .human) ? .computer : .human
//        }
//    }
//    
//    private func makeComputerMove() {
//        guard currentPlayer == .computer && !gameOver else { return }
//        
//        // Try to find winning move
//        if let winningMove = findBestMove(for: .computer) {
//            makeMove(at: winningMove)
//            return
//        }
//        
//        // Try to block player's winning move
//        if let blockingMove = findBestMove(for: .human) {
//            makeMove(at: blockingMove)
//            return
//        }
//        
//        // Make random move if no strategic moves available
//        var availablePositions = [Position]()
//        for row in 0..<3 {
//            for col in 0..<3 {
//                if board[row][col] == .none {
//                    availablePositions.append(Position(row: row, col: col))
//                }
//            }
//        }
//        
//        if let randomPosition = availablePositions.randomElement() {
//            makeMove(at: randomPosition)
//        }
//    }
//    
//    private func findBestMove(for player: Player) -> Position? {
//        // Check for winning moves
//        for row in 0..<3 {
//            for col in 0..<3 {
//                let position = Position(row: row, col: col)
//                if board[row][col] == .none {
//                    // Try move
//                    board[row][col] = player
//                    if checkWin(for: player) {
//                        // Undo move and return position if it's a winning move
//                        board[row][col] = .none
//                        return position
//                    }
//                    // Undo move if not winning
//                    board[row][col] = .none
//                }
//            }
//        }
//        return nil
//    }
//    
//    private func applyPowerUp(_ powerUp: PowerUp, at position: Position) {
//        switch powerUp {
//        case .wildCard:
//            // Place an extra mark anywhere
//            alertMessage = "Wild Card: Place an extra mark!"
//            showAlert = true
//        case .steal:
//            // Steal opponent's mark
//            for row in 0..<3 {
//                for col in 0..<3 {
//                    if board[row][col] == (currentPlayer == .human ? .computer : .human) {
//                        board[row][col] = currentPlayer
//                        return
//                    }
//                }
//            }
//        case .reverse:
//            // Reverse the last move
//            board[position.row][position.col] = .none
//            alertMessage = "Reverse: Your opponent's last move was undone!"
//            showAlert = true
//        }
//    }
//    
//    private func handleWin(for player: Player) {
//        if player == .human {
//            computerHealth -= 1
//            alertMessage = computerHealth > 0 ? "You won this round!" : "You won the game!"
//        } else {
//            humanHealth -= 1
//            alertMessage = humanHealth > 0 ? "Computer won this round!" : "Computer won the game!"
//        }
//        
//        gameOver = humanHealth == 0 || computerHealth == 0
//        showAlert = true
//        
//        if !gameOver {
//            resetBoard()
//        }
//    }
//    
//    private func handleDraw() {
//        alertMessage = "It's a draw!"
//        showAlert = true
//        resetBoard()
//    }
//    
//    private func checkWin(for player: Player) -> Bool {
//        // Check rows and columns
//        for i in 0..<3 {
//            if board[i].allSatisfy({ $0 == player }) ||
//                board.map({ $0[i] }).allSatisfy({ $0 == player }) {
//                return true
//            }
//        }
//        
//        // Check diagonals
//        if (board[0][0] == player && board[1][1] == player && board[2][2] == player) ||
//            (board[0][2] == player && board[1][1] == player && board[2][0] == player) {
//            return true
//        }
//        
//        return false
//    }
//    
//    private func isBoardFull() -> Bool {
//        return !board.contains { $0.contains(.none) }
//    }
//    
//    private func resetBoard() {
//        board = Array(repeating: Array(repeating: .none, count: 3), count: 3)
//        currentPlayer = .human
//        setupPowerSquares()
//    }
//    
//    private func resetGame() {
//        humanHealth = 3
//        computerHealth = 3
//        gameOver = false
//        winner = nil
//        resetBoard()
//    }
//    
//    private func setupPowerSquares() {
//        powerSquares.removeAll()
//        // Add 1-2 random power-ups
//        let numberOfPowerUps = Int.random(in: 1...2)
//        for _ in 0..<numberOfPowerUps {
//            let position = Position(row: Int.random(in: 0..<3), col: Int.random(in: 0..<3))
//            if board[position.row][position.col] == .none {
//                powerSquares[position] = PowerUp.allCases.randomElement()!
//            }
//        }
//    }
//}
//
//
////
//struct GameSquare: View {
//    let symbol: String
//    let isPowerSquare: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(Color(hex: "#581845").opacity(0.2))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(isPowerSquare ? Color.yellow : Color.clear, lineWidth: 2)
//                    )
//                Text(symbol)
//                    .font(.system(size: 40, weight: .bold))
//                    .foregroundColor(Color(hex: "#581845"))
//            }
//        }
//        .frame(width: 80, height: 80)
//    }
//}
//
//
//#Preview {
//    ContentView()
//}
