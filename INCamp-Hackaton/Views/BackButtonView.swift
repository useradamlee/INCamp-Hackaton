//
//  BackButtonView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct BackButtonView: View {
    let primaryColor: Color
    @Binding var showingAlert: Bool
    @Binding var navigateToHome: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                showingAlert = true
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundColor(primaryColor)
                    Text("Home")
                        .font(.title2)
                        .foregroundColor(primaryColor)
                }
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    BackButtonView(primaryColor: Color(hex: "#FFC312"), showingAlert: .constant(false), navigateToHome: .constant(false))
}
