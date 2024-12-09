//
//  RecommendView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct RecommendView: View {
    @State var playLists: [SpotifyPlayList] = [] // TODO: recommendList 구해야함
    @State var recommend: SpotifyRecommend?
    @State var me        : SpotifyUser? // State로 두어야 무한 스크롤의 결과가 바로 표시됨
    @Environment(\.colorScheme) var colorSchema

    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

    var body: some View {
        VStack {
            Text("추천 플레이리스트")
                .font(.title)
                .padding(.top, 20)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(playLists, id: \.playListId) { playlist in
                        NavigationLink(destination: PlayListView(playlist: playlist)) {
                            VStack {
                                AsyncImage(url: URL(string: playlist.imageURL ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                }
                                CustomScrollText(text: playlist.title ?? "Empty")
                                    .foregroundColor(colorSchema == .dark ? .white : .black)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(colorSchema == .dark ? .secondarySystemBackground : .systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                        }
                        .onAppear {
                            Task {
                                let lastIndex = playLists.count - 1
                                if playlist.playListId == playLists[lastIndex].playListId {
                                    playLists = await me?.playList(idx: -1) ?? []
                                }
                            }
                        }
                    }
                }.padding(.horizontal, 2)
            }
            .padding(.horizontal)
        }
        .task {
            self.me = SpotifyUser(userId: nil)
            
            if let me = me {
                playLists = await me.playList(idx: -1)
            }
        }
    }
}

#Preview {
    MainView()
}
