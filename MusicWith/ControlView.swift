//
//  ControlView.swift
//  HappyTest
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct ControlView: View {
    @State private var selection = 0
    @EnvironmentObject var controlState: ControlState
   
    var body: some View {
        
        VStack(spacing: 0) {
            ControlCoreView()
            CustomTabView(isTop: true, selection: $selection, tabCount: 2) {
                LyricsView()
                        .tag(0)
                ChatView()
                        .tag(1)
            }
            Spacer()
        }
    }
}

#Preview {
    MainView()
}
