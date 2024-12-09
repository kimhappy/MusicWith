//
//  SearchView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct SearchView: View {
    @State       var spotifySearch   : SpotifySearch?
    @State       var searchedSongList: [SpotifyTrack] = []
    @State       var isSearched      : Bool           = false // isSearched
    @State       var searchText      : String         = ""    // 검색할 String
    @State       var searchNum       : Int            = 0     // Search Index 용도, 변화 X
    @State       var recentSearchList                 = RecentSearch().myRecentSearches()
    @StateObject var recentSearch                     = RecentSearch()
    @StateObject var controlState                     = ControlState.shared

    private func deleteSearch() {
        searchText       = ""
        isSearched       = false
        spotifySearch    = nil
        searchedSongList = []
    }

    private func sendSearch() async {
        // TODO: Implement Search and get Playlists
        spotifySearch           = SpotifySearch(query: searchText)
        searchedSongList        = []
        guard let searchSuccess = spotifySearch else {return }

        searchedSongList = await searchSuccess.track(idx: searchNum)
        recentSearch.addRecentSearch(searchText)
        recentSearchList = recentSearch.myRecentSearches()
        isSearched = true
    }

    private func tapRecent(_ term : String) async{
        searchText = term
        await sendSearch()
    }

    private func deleteRecent(_ term : String) {
        recentSearch.deleteRecentSearch(term)
        recentSearchList = recentSearch.myRecentSearches()
    }

    var body: some View {
        VStack {
            Text("음악 검색")
                .font(.title)
                .padding(.top, 20)

            TextField("Search :", text: $searchText)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)

                        if !searchText.isEmpty {
                            Button(action: {
                                deleteSearch()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }

                    }
                )
                .padding(.horizontal, 10)
                .onSubmit {
                    Task {
                        if !searchText.isEmpty {
                            await sendSearch()
                        }
                    }
                }
                .onChange(of: searchText) {
                    if searchText == "" {
                        isSearched = false
                    }
                }

            if isSearched {
                ScrollView {
                    LazyVStack {
                        ForEach(searchedSongList, id: \.trackId) { song in
                            HStack {
                                AsyncImage(url: URL(string: song.imageURL ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                }
                                CustomScrollText(text: song.title ?? "None")
                                    .padding(.leading, 20)
                                Spacer()
                            }
                            .padding(.vertical, 5)
                            .onTapGesture {
                                Task {
                                    await controlState.setSong(song: song)
                                }
                            }
                            .onAppear {
                                Task {
                                    // 무한 스크롤 구현 용도, 마지막 것이 출력되면 data 추가 요청
                                    let lastIndex = searchedSongList.count - 1

                                    if song.trackId == searchedSongList[lastIndex].trackId {
                                        searchedSongList = await spotifySearch?.track(idx: searchNum) ?? []
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            else {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(recentSearchList, id: \.self) { term in
                            HStack {
                                Text(term)
                                    .padding(.vertical, 8)
                                Spacer()
                                Button(action: {
                                    deleteRecent(term)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.horizontal)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .onTapGesture {
                                Task {
                                    await tapRecent(term)
                                }
                            }
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
        }
    }
}
