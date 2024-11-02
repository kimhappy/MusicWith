//
//  SearchView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct SearchView: View {
    @State var searchedPlayLists = PlayList.myPlayLists();
    @State var isSearched = false;
    @State private var searchText = "";
    
    var body: some View {
        VStack {
            Text("플레이리스트 검색")
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
                                self.searchText = ""
                                isSearched = false;
                                searchedPlayLists = [];
                                
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
                    isSearched = true;
                    
                    // Todo Implement Search and get Playlists
                    searchedPlayLists = PlayList.myPlayLists();
                    
                }
        
            
            
            if isSearched {
                ScrollView {
                    LazyVStack {
                        ForEach(searchedPlayLists, id: \.id) { playlist in
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
            
            else {
                Spacer()
            }
        }
        
        
    }
}

#Preview {
    SearchView()
}
