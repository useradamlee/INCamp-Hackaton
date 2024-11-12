//
//  HealthView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct HealthView: View {
    let player: String
    let health: Int
    let color: Color
    
    var body: some View {
        VStack {
            Text(player)
                .font(.headline)
                .foregroundColor(.black)
            HStack {
                ForEach(0..<3) { i in
                    Image(systemName: i < health ? "heart.fill" : "heart")
                        .foregroundColor(color)
                        .shadow(radius: 1)
                }
            }
        }
    }
}

#Preview {
    HealthView(player: "Human", health: 3, color: Color(hex: "#FFC312"))
}

