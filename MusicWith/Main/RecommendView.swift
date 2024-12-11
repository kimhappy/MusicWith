//
//  RecommendView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI
import Combine

struct RecommendView: View {
    @Environment(\.colorScheme) private var _colorSchema

    private let _columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    public var body: some View {
        VStack {
            Text("현재 인기 있는 음악")
                .font(.title)
                .padding(.top, 20)
            Text("공사중~")
            // ScrollView {
            //     LazyVGrid(columns: columns, spacing: 16) {
            //         ForEach(tracks, id: \.trackId) { song in
            //             VStack {
            //                 AsyncImage(url: URL(string: song.imageURL ?? "")) { image in
            //                     image
            //                         .resizable()
            //                         .aspectRatio(contentMode: .fill)
            //                         .frame(width: 100, height: 100)
            //                         .clipped()
            //                 } placeholder: {
            //                     ProgressView()
            //                         .frame(width: 100, height: 100)
            //                 }
            //                 CustomScrollText(text: song.title ?? "Empty", alignment: .center)
            //                     .foregroundColor(colorSchema == .dark ? .white : .black)

            //                 Spacer()
            //             }
            //             .frame(maxWidth: .infinity)
            //             .padding()
            //             .background(Color(colorSchema == .dark ? .secondarySystemBackground : .systemBackground))
            //             .cornerRadius(12)
            //             .shadow(radius: 2)
            //             .onTapGesture {
            //                 Task {
            //                     await controlState.setSong(song: song)
            //                 }
            //             }
            //             .onAppear {
            //                 Task {
            //                     if song.trackId == tracks[tracks.count - 1].trackId {
            //                         // Infinite Scroll
            //                     }
            //                 }
            //             }
            //         }
            //     }.padding(.horizontal, 2)
            // }
            .padding(.horizontal)
        }
        .task {
            // test 원할 시 만든 Playlist 중에서 변경
//            let playlist = SpotifyPlayList(playListId: "4yChwi9z4WjV2ppkIjwaxm")
//            tracks = await playlist.track(idx: -1)
        }
    }
}
