//
//  BackButtonView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

import SwiftUI

struct BackButtonView: View {
    let primaryColor: Color
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(primaryColor)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    BackButtonView(primaryColor: Color(hex: "#FFC312"))
}

