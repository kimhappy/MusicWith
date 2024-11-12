//
//  RecommendView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct RecommendView: View {
    @State var playLists : [SpotifyPlayList]    = [] // 추후 recommendList 구할 필요가 있다.
    @State var showNumber                       = 10;
    let increasingNum                           = 10;

    var body: some View {
        VStack {
            Text("추천 플레이리스트")
                .font(.title)
                .padding(.top, 20)
            ScrollView {
                LazyVStack {
                    ForEach(playLists, id: \.playListId) { playlist in
                        var imageUrl = ""
                        var name = ""
                        NavigationLink(destination: PlayListView(playlist: playlist)) {
                            HStack {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                }
                                Text(name)
                                    .foregroundColor(.black)
                                    .padding(.leading, 20)
                                Spacer()
                            }
                            .padding(.vertical, 5)
                        }
                        .task {
                            imageUrl = await playlist.imageUrls()?[0] ?? "image" // Image 1개만 필요?
                            name = await playlist.name() ?? "Name"
                        }
                        .onAppear {
                            // Search에서 URL 확인 후에 구현
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .task {
            // Recommend Api 가져온 후에 변경
            let me   = SpotifyUser(userId: nil)
            playLists = await me.playList(idx: showNumber)
        }
    }
}

#Preview {
    MainView()
}
