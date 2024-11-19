//
//  RecommendView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct RecommendView: View {
    @State var playLists : [SpotifyPlayList]    = [] // 추후 recommendList 구할 필요가 있다.
    @State var recommend : SpotifyRecommend?

    var body: some View {
        VStack {
            Text("추천 플레이리스트")
                .font(.title)
                .padding(.top, 20)
            ScrollView {
                LazyVStack {
                    ForEach(playLists, id: \.playListId) { playlist in
                        NavigationLink(destination: PlayListView(playlist: playlist)) {
                            HStack {
                                AsyncImage(url: URL(string: playlist.imageURL ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                }
                                Text(playlist.title ?? "Empty")
                                    .foregroundColor(.black)
                                    .padding(.leading, 20)
                                Spacer()
                            }
                            .padding(.vertical, 5)
                        }
                        .onAppear {
                            Task {
                                let lastIndex = playLists.count - 1
                                if playlist.playListId == playLists[lastIndex].playListId {
                                    playLists = await recommend?.playList(idx: 0) ?? []
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .task {
            recommend = SpotifyRecommend()
            playLists = await recommend?.playList(idx: 0) ?? []
        }
    }
}

#Preview {
    MainView()
}
