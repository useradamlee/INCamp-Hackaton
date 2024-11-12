//
//  DetailedGameHistoryView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct DetailedGameHistoryView: View {
    var gameHistory: GameHistory
    
    var body: some View {
        ZStack {
            Color(hex: "#FFC312").edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Text("Date: \(gameHistory.date)")
                    .font(.headline)
                Text("Summary: \(gameHistory.summary)")
                    .font(.subheadline)
                // Add more detailed information about the game here
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .padding()
        }
        .navigationTitle("Detailed Game History")
    }
}

#Preview {
    DetailedGameHistoryView(gameHistory: GameHistory(date: "2024-11-10", summary: "Player A vs Player B"))
}
