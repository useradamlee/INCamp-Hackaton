import SwiftUI

struct DifficultySelectionView: View {
    @Binding var isPresented: Bool
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var showGame = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Select Difficulty")
                    .font(.largeTitle)
                    .padding()
                
                Picker("Difficulty", selection: $selectedDifficulty) {
                    Text("Easy").tag(Difficulty.easy)
                    Text("Medium").tag(Difficulty.medium)
                    Text("Hard").tag(Difficulty.hard)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button(action: {
                    showGame = true
                    isPresented = false
                }) {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(hex: "#FFC312"))
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
            .fullScreenCover(isPresented: $showGame) {
                GameView(gameMode: .computer, difficulty: selectedDifficulty)
            }
        }
    }
}

#Preview {
    DifficultySelectionView(isPresented: .constant(true))
}
