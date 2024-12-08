//
//  MainView.swift
//  HappyTest
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct MainView: View {
    @State private var selectedDetent = SheetHeight.mini.detent()
    @State private var selection      = 0

    @StateObject private var controlState = ControlState.shared
    @StateObject private var spotify      = SpotifyAPI  .shared

    var body: some View {
        if spotify.isLoggedIn {
            VStack(spacing: 0) {
                NavigationStack {
                    CustomTabView(isTop: true, selection: $selection, tabCount: 3) {
                        PlayListsView()
                            .tag(0)
                        RecommendView()
                            .tag(1)
                        SearchView()
                            .tag(2)
                    }
                }
            }
            .sheet(isPresented: $controlState.showSheet) {
                ControlView()
                    .presentationDetents([SheetHeight.mini.detent(), SheetHeight.full.detent()], selection: $selectedDetent)
                    .presentationBackgroundInteraction(.enabled)
                    .onChange(of: selectedDetent) { newValue in
                        if newValue == SheetHeight.mini.detent() {
                            controlState.sheetHeight = .mini
                        }
                        else {
                            controlState.sheetHeight = .full
                        }
                    }
            }
        }
        else {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.pink]),
                               startPoint: .top,
                               endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100) // Adjust size as needed
                    .foregroundColor(Color.white.opacity(0.2)) // Subtle appearance
                    .rotationEffect(.degrees(-30)) // Slight til
                    .offset(x: 120, y: -200) // Move it to the right side
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100) // Adjust size as needed
                    .foregroundColor(Color.white.opacity(0.2)) // Subtle appearance
                    .rotationEffect(.degrees(10)) // Slight til
                    .offset(x: -100, y: 240) // Move it to the right side
                VStack {
                    Spacer()
                    Text("MusicWith")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.black)

                    Text("Chatting and Listening music")
                        .font(.headline)
                        .fontDesign(.monospaced)
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: {
                        spotify.login()
                    }) {
                        HStack {
                            Image(systemName: "waveform.path.ecg") // Placeholder for Tidal logo
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)

                            Text("Login with Tidal")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.gray]),
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
        }
    }
}
