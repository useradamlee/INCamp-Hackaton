//
//  DifficultySelectionView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct DifficultySelectionView: View {
    @State private var selectedDifficulty: Difficulty = .medium
    
    var body: some View {
        NavigationView {
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
            .navigationTitle("Difficulty Selection")
            .navigationBarItems(leading: Button(action: {
                // Navigation back action
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color(hex: "#FFC312"))
                Text("Back")
                    .foregroundColor(Color(hex: "#FFC312"))
            })
        }
    }
}

#Preview {
    DifficultySelectionView()
}
