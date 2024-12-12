//
//  PlayListsView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct PlayListsView: View {
    @Environment(\.colorScheme) private var _colorSchema

    @State private var _userName   :  String          = ""
    @State private var _playListIds: [String]         = []
    @State private var _names      : [String: String] = [:]
    @State private var _imageUrls  : [String: String] = [:]

    @State private var _refresh: Bool = false

    var body: some View {
        ZStack {
            VStack {
                Text("\(_userName)의 플레이리스트")
                    .font   (.title)
                    .padding(.top, 20)
                ScrollView {
                    LazyVStack {
                        ForEach(_playListIds, id: \.self) { playListId in
                            NavigationLink(destination: PlayListView(playListId: playListId)) {
                                HStack {
                                    AsyncImage(url: URL(string: _imageUrls[ playListId ] ?? "https://placehold.co/80")) { image in
                                        image
                                            .resizable  ()
                                            .aspectRatio(contentMode: .fill)
                                            .frame      (width: 50, height: 50)
                                            .clipped    ()
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 50, height: 50)
                                    }
                                    CustomScrollText(text: _names[ playListId ] ?? "")
                                        .foregroundColor(_colorSchema == .dark ? .white : .black)
                                        .padding        (.leading, 20)
                                    Spacer()
                                }
                                .padding(.vertical, 5)
                            }
                            .task {
                                if case nil = _names[ playListId ] {
                                    let name     = await PlayList.name    (playListId)
                                    let imageUrl = await PlayList.imageUrl(playListId)

                                    DispatchQueue.main.async {
                                        _names    [ playListId ] = name
                                        _imageUrls[ playListId ] = imageUrl
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .task {
                if let myUserId = await User.myUserId() {
                    _userName    = await User    .name         (myUserId) ?? "나"
                    _playListIds = await PlayList.myPlayListIds()         ?? []
                }
            }
            Button(action: { Auth.shared.logout() }) {
                Text("logout")
                    .font           (.system(size: 14, weight: .semibold))      // 작은 글씨 크기, 볼드체
                    .padding        (10)                                        // 버튼 안의 여백
                    .foregroundColor(Color.gray)                                // 텍스트 색상
                    .cornerRadius   (10)                                        // 둥근 모서리
                    .shadow         (color: Color.gray.opacity(0.3), radius: 5) // 약간 흐릿한 그림자 효과
            }
            .offset(x: 165, y: -320)
        }
    }
}
