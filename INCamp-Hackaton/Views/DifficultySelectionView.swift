import SwiftUI

struct DifficultySelectionView: View {
    @Binding var isPresented: Bool
    @State private var selectedDifficulty: Difficulty = .medium
    @Environment(\.dismiss) var dismiss
    
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
                    dismiss()
                    // We need to add a slight delay to allow the sheet to dismiss
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPresented = false
                        // Present the GameView as a full-screen cover
                        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                        let window = windowScene?.windows.first
                        let gameView = UIHostingController(rootView: GameView(gameMode: .computer, difficulty: selectedDifficulty))
                        window?.rootViewController?.present(gameView, animated: true)
                    }
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
        }
    }
}

#Preview {
    DifficultySelectionView(isPresented: .constant(true))
}
