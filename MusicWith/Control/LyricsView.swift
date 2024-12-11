//
//  LyricsView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct LyricsView: View {
    @State private var _lyric = ""

    public var body: some View {
        VStack {
            Text("가사")
                .padding(.top, 30)
                .font(.system(size: 20, weight: .semibold))
            ScrollView {
                Text(_lyric)
                    .lineSpacing(30)
                    .offset(y: 30)
                    .padding(30)
            }
        }
        .task {
            if let info   = TrackPlayer.shared.info(),
               let lyrics = await Track.lyrics(info.trackId) {
                _lyric = lyrics.map(\.content).joined(separator: "\n")
            }
        }
    }
}
