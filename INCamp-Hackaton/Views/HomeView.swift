//
//  HomeView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct HomeView: View {
    let primaryColor = Color(hex: "#CC9C0E") // Darker shade of the existing color

    var body: some View {
        TabView {
            NavigationView {
                ZStack {
                    Color(hex: "#FFC312").edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 40) {
                        Text("Tickle That Toe")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(15)
                        
                        VStack(spacing: 20) {
                            // Player vs Player Mode
                            NavigationLink(destination: GameView(gameMode: .pvp, difficulty: .easy)) {
                                GameModeButton(title: "Player vs Player", imageName: "person.2.fill", color: Color.black.opacity(0.8))
                            }
                            
                            // Player vs Computer Mode
                            NavigationLink(destination: GameView(gameMode: .computer, difficulty: .medium)) { // Add difficulty parameter here
                                GameModeButton(title: "Player vs Computer", imageName: "desktopcomputer", color: Color.black.opacity(0.8))
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                        
                        Spacer()
                    }
                    .padding()
                }
                .navigationBarHidden(true) // Hide the navigation bar for cleaner UI
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            GameHistoryView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Game History")
                }
        }
        .accentColor(primaryColor) // Set the tab bar theme color
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
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    HomeView()
}
