import SwiftUI

struct DifficultySelectionView: View {
    @Binding var isPresented: Bool
    @Binding var selectedDifficulty: Difficulty?
    @Binding var navigateToGame: Bool
    @State private var tempSelectedDifficulty: Difficulty = .medium

    var body: some View {
        NavigationStack {
            VStack {
                Text("Select Difficulty")
                    .font(.largeTitle)
                    .padding()
                
                Picker("Difficulty", selection: $tempSelectedDifficulty) {
                    Text("Easy").tag(Difficulty.easy)
                    Text("Medium").tag(Difficulty.medium)
                    Text("Hard").tag(Difficulty.hard)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button(action: {
                    selectedDifficulty = tempSelectedDifficulty  // Set the selected difficulty
                    isPresented = false                         // Dismiss sheet
                    navigateToGame = true                       // Trigger navigation in parent
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
