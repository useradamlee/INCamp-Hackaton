//
//  CurrentPlayerIndicatorView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct CurrentPlayerIndicatorView: View {
    let currentPlayer: Player

    var body: some View {
        Text("\(currentPlayer.displayName)'s Turn")
            .font(.headline)
            .foregroundColor(.black)
            .padding(.top)
    }
}

#Preview {
    CurrentPlayerIndicatorView(currentPlayer: .first)
}
