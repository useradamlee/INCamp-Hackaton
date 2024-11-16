import SwiftUI

struct HomeView: View {
    let primaryColor = Color(hex: "#CC9C0E")
    @State private var showingDifficultySelection = false
    @State private var showingGame = false
    @State private var gameConfig: (mode: GameMode, difficulty: Difficulty)?
    
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
                            Button(action: {
                                gameConfig = (.pvp, .easy)
                                showingGame = true
                            }) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .font(.title2)
                                    Text("Player vs Player")
                                        .font(.title3)
                                        .bold()
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(15)
                                .shadow(radius: 5)
                            }
                            
                            Button(action: {
                                showingDifficultySelection = true
                            }) {
                                HStack {
                                    Image(systemName: "desktopcomputer")
                                        .font(.title2)
                                    Text("Player vs Computer")
                                        .font(.title3)
                                        .bold()
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(15)
                                .shadow(radius: 5)
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
                .navigationBarHidden(true)
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
        .accentColor(primaryColor)
        .sheet(isPresented: $showingDifficultySelection) {
            DifficultySelectionView(isPresented: $showingDifficultySelection,
                                  showingGame: $showingGame,
                                  gameConfig: $gameConfig)
        }
        .fullScreenCover(isPresented: $showingGame) {
            if let config = gameConfig {
                GameView(gameMode: config.mode, difficulty: config.difficulty)
            }
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
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

#Preview {
    HomeView()
}
