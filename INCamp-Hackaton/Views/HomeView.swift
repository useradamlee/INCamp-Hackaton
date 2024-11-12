//
//  HomeView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct HomeView: View {
    let primaryColor = Color(hex: "#FFC312")
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Tickle That Toe")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                    .padding()
                
                VStack(spacing: 20) {
                    // Player vs Player Mode
                    NavigationLink(destination: GameView(gameMode: .pvp)) {
                        GameModeButton(title: "Player vs Player", imageName: "person.2.fill", color: primaryColor)
                    }
                    
                    // Player vs Computer Mode
                    NavigationLink(destination: GameView(gameMode: .computer)) {
                        GameModeButton(title: "Player vs Computer", imageName: "desktopcomputer", color: primaryColor)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationBarHidden(true) // Hide the navigation bar for cleaner UI
        }
    }
}

struct GameModeButton: View {
    let title: String
    let imageName: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .font(.title2)
            Text(title)
                .font(.title3)
                .bold()
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

#Preview {
    HomeView()
}
