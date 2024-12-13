//
//  LyricsView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct LyricsView: View {
    @StateObject        private var _tps    = TrackPlayer.shared
    @State              private var _lyrics: [Lyric] = []
    @Environment(\.colorScheme) var colorSchema

    public var body: some View {
        VStack {
            Text("가사")
                .padding(.top, 30)
                .font(.system(size: 20, weight: .semibold))
            ScrollView {
                ForEach(0..<_lyrics.count, id: \.self) { index in
                    if _lyrics.count-1 == index {
                        Text(_lyrics[index].content)
                            .foregroundColor(_lyrics[index].begin<=_tps.info()!.now ? .blue : colorSchema == .dark ? .white : .black)
                            .padding()
                    }
                    else {
                        Text(_lyrics[index].content)
                            .foregroundColor(_lyrics[index].begin<=_tps.info()!.now && _tps.info()!.now < _lyrics[index+1].begin ? .blue : colorSchema == .dark ? .white : .black)
                            .padding()
                    }
                }
            }
        }
        .task(id: _tps.info()!.trackId) {
            let trackId = _tps.info()!.trackId
            let lyrics  = await Track.lyrics(trackId) ?? []
            _lyrics = lyrics
            //_lyrics = lyrics.map(\.content).joined(separator: "\n")
        }
    }
}
