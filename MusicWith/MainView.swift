//
//  MainView.swift
//  HappyTest
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct MainView: View {
    static let mini = PresentationDetent.fraction(0.15)
    static let full = PresentationDetent.large

    @State private var selectedDetent = mini
    @State private var selection      = 0

    @StateObject private var controlState = ControlState()

    var body: some View {
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
        .environmentObject(controlState)
        .sheet(isPresented: $controlState.showSheet) {
            ControlView()
                .presentationDetents([MainView.mini, MainView.full], selection: $selectedDetent)
                .presentationBackgroundInteraction(.enabled)
                .environmentObject(controlState)
        }
    }
}

#Preview {
    MainView()
}
