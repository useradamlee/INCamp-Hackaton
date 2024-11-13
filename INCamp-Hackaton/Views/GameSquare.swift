//
//  GameSquare.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct GameSquare: View {
    let symbol: String
    let isPowerSquare: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "#CC9C0E").opacity(0.2)) // Darker shade for better contrast
                    .stroke(isPowerSquare ? Color.yellow : Color.clear, lineWidth: 2)
                    .foregroundColor(Color(hex: "#664E07")) // Darker shade for text
                Text(symbol)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(hex: "#664e07"))
            }
        }
        .frame(width: 80, height: 80)
    }
}

#Preview {
    GameSquare(symbol: "X", isPowerSquare: true, action: { })
}

