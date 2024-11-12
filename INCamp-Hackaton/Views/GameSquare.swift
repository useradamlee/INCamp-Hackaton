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
                    .fill(Color(hex: "#581845").opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isPowerSquare ? Color.yellow : Color.clear, lineWidth: 2)
                    )
                Text(symbol)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(hex: "#581845"))
            }
        }
        .frame(width: 80, height: 80)
    }
}

#Preview {
    GameSquare(symbol: "X", isPowerSquare: true, action: { })
}

