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
                ForEach(0..<_trackIds.count, id: \.self) { index in
                    HStack {
                        AsyncImage(url: URL(string: _imageUrls[ _trackIds[ index ] ] ?? "https://placehold.co/80")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                                .frame(width: 50, height: 50)
                        }
                        CustomScrollText(text: _names[ _trackIds[ index ] ] ?? "")
                            .padding(.leading, 20)
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    .onTapGesture {
                        TrackPlayer     .shared.setTrack(_trackIds, index)
                        ControlViewState.shared.showSheet = true
                    }
                    .task {
                        if case nil = _names[ _trackIds[ index ] ] {
                            let name     = await Track.name    (_trackIds[ index ])
                            let imageUrl = await Track.imageUrl(_trackIds[ index ])

                            DispatchQueue.main.async {
                                _names    [ _trackIds[ index ] ] = name
                                _imageUrls[ _trackIds[ index ] ] = imageUrl
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
