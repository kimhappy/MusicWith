//
//  ControlView.swift
//  HappyTest
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct ControlView: View {
    @State       private var _selection = 0
    @StateObject private var _cvss      = ControlViewState.shared

    public var body: some View {
        if case .mini = _cvss.sheetHeight {
            VStack(spacing: 0) {
                ControlCoreView()
                Spacer()
            }
        }
        else {
            VStack(spacing: 0) {
                ControlCoreView()
                CustomTabView(isTop: false, selection: $_selection, tabCount: 2) {
                    LyricsView()
                        .tag(0)
                    ChatView()
                        .tag(1)
                }
                Spacer()
            }
        }
    }
}
