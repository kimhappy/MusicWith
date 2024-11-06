//
//  LyricsView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct LyricsView: View {
    @StateObject var controlState = ControlState.shared
    
    var body: some View {
        if let state = controlState.playState {
            VStack {
                Text("가사")
                    .padding(.top, 30)
                    .font(.system(size: 20, weight: .semibold))
                ScrollView {
                    Text(state.song.lyric)
                        .lineSpacing(30)
                        .offset(y:30)
                        .padding(30)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
