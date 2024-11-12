//
//  BackButtonView.swift
//  INCamp-Hackaton
//
//  Created by Lee Jun Lei Adam on 12/11/24.
//

//import SwiftUI
//
//struct BackButtonView: View {
//    let primaryColor: Color
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        HStack {
//            Button(action: {
//                // Navigate back to HomeView
//                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                   let window = windowScene.windows.first {
//                    window.rootViewController = UIHostingController(rootView: HomeView())
//                    window.makeKeyAndVisible()
//                }
//            }) {
//                HStack {
//                    Image(systemName: "chevron.left")
//                        .font(.title)
//                        .foregroundColor(primaryColor)
//                    Text("Home")
//                        .font(.title2)
//                        .foregroundColor(primaryColor)
//                }
//            }
//            Spacer()
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    BackButtonView(primaryColor: Color(hex: "#FFC312"))
//}
