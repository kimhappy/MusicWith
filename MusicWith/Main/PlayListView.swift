//
//  PlayListDetailView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct PlayListView: View {
    let playlist: PlayList

    @EnvironmentObject var controlState: ControlState

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(playlist.songs, id: \.id) { song in
                    HStack {
                        AsyncImage(url: URL(string: song.image)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                                .frame(width: 50, height: 50)
                        }
                        Text(song.title)
                            .padding(.leading, 20)
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    .onTapGesture {
                        // TODO: Fallback control
                        controlState.setSong(song: song)
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle(playlist.name)
    }
}


#Preview {
    MainView()
}
