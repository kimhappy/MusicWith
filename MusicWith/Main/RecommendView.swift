//
//  RecommendView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct RecommendView: View {
    @Environment(\.colorScheme) private var _colorSchema
    
    @State private var _tracks   : [(String, Int) ] = []
    @State private var _names    : [String: String] = [:]
    @State private var _imageUrls: [String: String] = [:]

    private let _columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    @MainActor
    private func loadTrackDataForIndex(_ index: Int) async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let name = await Track.name(_tracks[index].0)
        let imageUrl = await Track.imageUrl(_tracks[index].0)
        
        _names[_tracks[index].0] = name
        _imageUrls[_tracks[index].0] = imageUrl
    }
    
    public var body: some View {
        VStack {
            Text("현재 인기 있는 음악")
                .font(.title)
                .padding(.top, 20)
             ScrollView {
                 LazyVGrid(columns: _columns, spacing: 16) {
                     ForEach(0..<_tracks.count, id: \.self) { index in
                         VStack {
                             AsyncImage(url: URL(string: _imageUrls[ _tracks[ index ].0 ] ?? "https://placehold.co/80")) { image in
                                 image
                                     .resizable()
                                     .aspectRatio(contentMode: .fill)
                                     .frame(width: 100, height: 100)
                                     .clipped()
                             } placeholder: {
                                 ProgressView()
                                     .frame(width: 100, height: 100)
                             }
                             CustomScrollText(text: _names[ _tracks[ index ].0 ] ?? "", alignment: .center)
                                 .foregroundColor(_colorSchema == .dark ? .white : .black)

                             Spacer()
                         }
                         .frame(maxWidth: .infinity)
                         .padding()
                         .background(Color(_colorSchema == .dark ? .secondarySystemBackground : .systemBackground))
                         .cornerRadius(12)
                         .shadow(radius: 2)
                         .onTapGesture {
                             TrackPlayer     .shared.setTrack(_tracks.map({ $0.0 }), index)
                             ControlViewState.shared.showSheet = true
                         }
                         .task {
                             if case nil = _names[ _tracks[ index ].0 ] {
                                 await loadTrackDataForIndex(index)
                             }
                         }
                     }
                 }.padding(.horizontal, 2)
             }
            .padding(.horizontal)
        }
        .task {
            _tracks = await RecommendTrack.tracks() ?? []
        }
    }
}

