//
//  ConfettiView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 13/11/24.
//

import SwiftUI

struct ConfettiView: View {
    @Binding var isShowing: Bool
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    @State private var confettiPieces: [ConfettiPiece] = []
    
    struct ConfettiPiece: Identifiable {
        let id = UUID()
        var position: CGPoint
        var color: Color
        var rotation: Double
        var scale: CGFloat
    }
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: 10, height: 10)
                    .position(x: piece.position.x, y: piece.position.y)
                    .rotationEffect(.degrees(piece.rotation))
                    .scaleEffect(piece.scale)
            }
        }
        .onChange(of: isShowing) { _, newValue in
            if newValue {
                createConfetti()
            }
        }
    }
    
    private func createConfetti() {
        confettiPieces.removeAll()
        
        // Create multiple confetti pieces
        for _ in 0..<100 {
            let piece = ConfettiPiece(
                position: CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: -50),
                color: colors.randomElement() ?? .red,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.5)
            )
            confettiPieces.append(piece)
        }
        
        // Animate confetti
        withAnimation(.easeOut(duration: 3.0)) {
            for index in confettiPieces.indices {
                confettiPieces[index].position.y = UIScreen.main.bounds.height + 50
                confettiPieces[index].rotation += Double.random(in: 180...720)
            }
        }
        
        // Hide confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isShowing = false
            confettiPieces.removeAll()
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showConfetti: Bool = false
        
        var body: some View {
            ZStack {
                Color.gray.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ConfettiView(isShowing: $showConfetti)
                    
                    Button("Trigger Confetti") {
                        showConfetti = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
    }
    
    return PreviewWrapper()
}
