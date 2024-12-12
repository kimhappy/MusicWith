//
//  LyricsView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct LyricsView: View {
    @StateObject private var _tps    = TrackPlayer.shared
    @State       private var _lyrics = ""

    public var body: some View {
        VStack {
            Text("가사")
                .padding(.top, 30)
                .font(.system(size: 20, weight: .semibold))
            ScrollView {
                Text(_lyrics)
                    .lineSpacing(30)
                    .offset(y: 30)
                    .padding(30)
            }
        }
        .task(id: _tps.info()!.trackId) {
            let trackId = _tps.info()!.trackId
            let lyrics  = await Track.lyrics(trackId) ?? []
            _lyrics = lyrics.map(\.content).joined(separator: "\n")
        }
    }
}
