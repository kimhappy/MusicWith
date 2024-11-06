//
//  SearchView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct SearchView: View {
    @State var searchedSongLists = PlayList(id: "temp").songs;
    @State private var isSearched = false;
    @State private var searchText = "";
    
    // 최근 검색어, Optional
    @StateObject private var recentSearch = RecentSearch()
    @StateObject var controlState = ControlState.shared
    
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
                    sendSearch()
                }
                .onChange(of: searchText) {
                    if searchText == "" {
                        isSearched = false
                    }
                }
        
            
            
            if isSearched {
                ScrollView {
                    LazyVStack {
                        ForEach(searchedSongLists, id: \.id) { song in
                            HStack {
                                AsyncImage(url: URL(string: song.image)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                }
                                Text(song.title)
                                    .padding(.leading, 20)
                                Spacer()
                            }
                            .padding(.vertical, 5)
                            .onTapGesture {
                                // TODO: Fallback control
                                controlState.setSong(song: song)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            
            // 최근 검색어, 필요 없다고 생각될 시 없애기
            else {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(recentSearch.myRecentSearch(), id: \.self) { term in
                            HStack {
                                Text(term)
                                    .padding(.vertical, 8)
                                Spacer()
                                // 삭제 버튼
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
                                tapRecent(term)
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
    
    private func deleteSearch() {
        searchText = ""
        isSearched = false;
        searchedSongLists = [];
    }
    
    private func sendSearch() {
        isSearched = true;
        
        // Todo Implement Search and get Playlists
        searchedSongLists = PlayList(id: "temp").songs;
        recentSearch.addRecentSearch(searchText)
    }
    
    // Recent Search is Optional
    private func tapRecent(_ term : String) {
        searchText = term;
        isSearched = true;
        // Todo Implement Search and get Playlists
        searchedSongLists = PlayList(id: "temp").songs;
    }
    
    private func deleteRecent(_ term : String) {
        recentSearch.deleteRecentSearch(term)
    }
}

#Preview {
    MainView()
}
