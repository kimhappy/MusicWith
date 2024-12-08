//
//  PlayListDetailView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct PlayListView: View {
    let playlist: SpotifyPlayList

    @State               var songList    : [SpotifyTrack] = []
    @State               var showNumber                   = 0;
    @StateObject         var controlState                 = ControlState.shared
    @State               var playListName                 = ""
    @State       private var isLoading                    = false

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(songList, id: \.trackId) { song in
                    HStack {
                        AsyncImage(url: URL(string: song.imageURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                                .frame(width: 50, height: 50)
                        }
                        CustomScrollText(text: song.title ?? "")
                            .padding(.leading, 20)
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    .onTapGesture {
                        // TODO: Fallback control
                        Task {
                            await controlState.setSong(song: song)
                            controlState.setPlaylist(playlist, song)
                            await controlState.setMusicIndex(playlist, song)
                        }
                    }
                    .onAppear {
                        Task {
                            if song.trackId == songList[songList.count - 1].trackId {
                                songList = await playlist.track(idx: showNumber)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle(playListName)
        .task {
            songList     = await playlist.track(idx: showNumber)
            playListName = await playlist.name() ?? "None"

            for song in songList {
                await song.name()
                await song.imageUrl()
            }
        }
    }
}
