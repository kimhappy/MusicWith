//
//  PlayListsView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct PlayListsView: View {
    @State var userName: String = ""

    let myPlayLists = PlayList.myPlayLists()

    var body: some View {
        VStack {
            Text("\(userName) 플레이리스트")
                .font(.title)
                .padding(.top, 20)
            ScrollView {
                LazyVStack {
                    ForEach(myPlayLists, id: \.id) { playlist in
                        NavigationLink(destination: PlayListView(playlist: playlist)) {
                            HStack {
                                AsyncImage(url: URL(string: playlist.image)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                }
                                Text(playlist.name)
                                    .foregroundColor(.black)
                                    .padding(.leading, 20)
                                Spacer()
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            SpotifyAPI.userName { name in
                DispatchQueue.main.async {
                    self.userName = if let name = name {
                        "\(name)의"
                    }
                    else {
                        "내"
                    }
                }
            }
        }
    }
}

#Preview {
    MainView()
}
