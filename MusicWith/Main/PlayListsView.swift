//
//  PlayListsView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct PlayListsView: View {
    @State                      var userName   : String               = ""
    @State                      var playLists  : [SpotifyPlayList]    = []
    @State                      var showNumber                        = -1
    @State                      var me         : SpotifyUser? // State로 두어야 무한 스크롤의 결과가 바로 표시됨
    @Environment(\.colorScheme) var colorSchema
    @StateObject                var spotify                           = SpotifyAPI  .shared

    var body: some View {
        ZStack {
            VStack {
                Text("\(userName)의 플레이리스트")
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
                                    CustomScrollText(text: playlist.title ?? "Error")
                                        .foregroundColor(colorSchema == .dark ? .white : .black)
                                        .padding(.leading, 20)
                                    Spacer()
                                }
                                .padding(.vertical, 5)
                            }
                            // Playlist 클릭 후 다시 돌아온 후 무한 스크롤 작동 안하는 문제 존재함, 위로 올렸다 내려야 함 onAppear 상시 작동 방법?
                            .onAppear {
                                Task {
                                    let lastIndex = playLists.count - 1
                                    if playlist.playListId == playLists[lastIndex].playListId {
                                        playLists = await me?.playList(idx: showNumber) ?? []
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .task {
                self.me = SpotifyUser(userId: nil)

                if let me = me {
                    userName  = await me.name() ?? "나"
                    playLists = await me.playList(idx: showNumber)
                }
            }
            Button(action: { spotify.logout() }) {
                Text("logout")
                    .font(.system(size: 14, weight: .semibold))        // 작은 글씨 크기, 볼드체
                    .padding(10)                                       // 버튼 안의 여백
                    .foregroundColor(Color.gray)                       // 텍스트 색상
                    .cornerRadius(10)                                  // 둥근 모서리
                    .shadow(color: Color.gray.opacity(0.3), radius: 5) // 약간 흐릿한 그림자 효과
            }
            .offset(x : 165, y : -320)
        }
    }
}
