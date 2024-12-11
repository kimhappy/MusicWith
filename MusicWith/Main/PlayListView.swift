//
//  PlayListDetailView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct PlayListView: View {
    public let playListId: String

    @State private var _playListName:  String  = ""
    @State private var _trackIds    : [String] = []
    @State private var _names       : [String: String] = [:]
    @State private var _imageUrls   : [String: String] = [:]

    public var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(_trackIds, id: \.self) { trackId in
                    HStack {
                        AsyncImage(url: URL(string: _imageUrls[ trackId ] ?? "https://placehold.co/80")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                                .frame(width: 50, height: 50)
                        }
                        CustomScrollText(text: _names[ trackId ] ?? "")
                            .padding(.leading, 20)
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    .onTapGesture {
                        TrackPlayer     .shared.setTrack(trackId)
                        ControlViewState.shared.showSheet = true
                    }
                    .task {
                        if case nil = _names[ trackId ] {
                            let name     = await Track.name    (trackId)
                            let imageUrl = await Track.imageUrl(trackId)

                            DispatchQueue.main.async {
                                _names    [ trackId ] = name
                                _imageUrls[ trackId ] = imageUrl
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .navigationTitle(_playListName)
        .task {
            _playListName = await PlayList.name    (playListId) ?? ""
            _trackIds     = await PlayList.trackIds(playListId) ?? []
        }
    }
}
