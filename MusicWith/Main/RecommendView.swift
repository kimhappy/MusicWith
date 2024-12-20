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
    
    @State private var _playListName:  String  = ""
    @State private var _trackIds    : [String] = []
    @State private var _names       : [String: String] = [:]
    @State private var _imageUrls   : [String: String] = [:]

    private let _columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    public var body: some View {
        VStack {
            Text("현재 인기 있는 음악")
                .font(.title)
                .padding(.top, 20)
             ScrollView {
                 LazyVGrid(columns: _columns, spacing: 16) {
                     ForEach(0..<_trackIds.count, id: \.self) { index in
                         VStack {
                             AsyncImage(url: URL(string: _imageUrls[ _trackIds[ index ] ] ?? "https://placehold.co/80")) { image in
                                 image
                                     .resizable()
                                     .aspectRatio(contentMode: .fill)
                                     .frame(width: 100, height: 100)
                                     .clipped()
                             } placeholder: {
                                 ProgressView()
                                     .frame(width: 100, height: 100)
                             }
                             CustomScrollText(text: _names[ _trackIds[ index ] ] ?? "", alignment: .center)
                                 .foregroundColor(_colorSchema == .dark ? .white : .black)

                             Spacer()
                         }
                         .frame(maxWidth: .infinity)
                         .padding()
                         .background(Color(_colorSchema == .dark ? .secondarySystemBackground : .systemBackground))
                         .cornerRadius(12)
                         .shadow(radius: 2)
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
                 }.padding(.horizontal, 2)
             }
            .padding(.horizontal)
        }
        .task {
            _trackIds     = await RecommendTrack.tracks()
        }
    }
}
