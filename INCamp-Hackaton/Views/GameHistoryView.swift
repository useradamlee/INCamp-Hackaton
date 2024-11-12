//
//  GameHistoryView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct GameHistoryView: View {
    var gameHistories: [GameHistory] = [
        GameHistory(date: "2024-11-10", summary: "Player A vs Player B"),
        GameHistory(date: "2024-11-11", summary: "Player C vs Player D"),
        // Add more game histories here
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#FFC312").edgesIgnoringSafeArea(.all)
                List(gameHistories) { gameHistory in
                    NavigationLink(destination: DetailedGameHistoryView(gameHistory: gameHistory)) {
                        VStack(alignment: .leading) {
                            Text(gameHistory.date)
                                .font(.headline)
                                .foregroundColor(.black)
                            Text(gameHistory.summary)
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .listRowBackground(Color.clear) // Make sure list row background is transparent
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Game History")
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

struct GameHistory: Identifiable {
    let id = UUID()
    let date: String
    let summary: String
}

#Preview {
    GameHistoryView()
}
