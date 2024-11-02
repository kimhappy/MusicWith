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
                .presentationDetents([SheetHeight.mini.detent(), SheetHeight.full.detent()], selection: $selectedDetent)
                .presentationBackgroundInteraction(.enabled)
                .environmentObject(controlState)
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
}

#Preview {
    MainView()
}
