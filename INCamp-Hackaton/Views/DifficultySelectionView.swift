import SwiftUI

struct DifficultySelectionView: View {
    @Binding var isPresented: Bool
    @State private var selectedDifficulty: Difficulty = .medium

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
                
                NavigationLink(destination: GameView(gameMode: .computer, difficulty: selectedDifficulty)) {
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
        }
    }
}

#Preview {
    DifficultySelectionView(isPresented: .constant(true))
}
