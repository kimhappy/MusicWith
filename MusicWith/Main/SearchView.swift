//
//  SearchView.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

struct SearchView: View {
    @State       private var _isSearched                      = false
    @State       private var _query                           = ""
    @State       private var _searchResults: [String]         = [] // trackId
    @State       private var _names        : [String: String] = [:]
    @State       private var _imageUrls    : [String: String] = [:]
    @StateObject private var _rss                             = RecentSearch.shared

    public var body: some View {
        VStack {
            Text("음악 검색")
                .font   (.title)
                .padding(.top, 20)

            TextField("Search:", text: $_query)
                .padding     (7)
                .padding     (.horizontal, 25)
                .background  (Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame          (minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding        (.leading, 8)

                        if !_query.isEmpty {
                            Button(action: {
                                _isSearched = false
                                _query      = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding        (.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onSubmit {
                    if !_query.isEmpty {
                        Task {
                            if let sr = await Search.tracks(_query) {
                                _rss.addRecentSearch(_query)
                                _searchResults = sr
                                _isSearched    = true
                            }
                        }
                    }
                }

            if _isSearched {
                ScrollView {
                    LazyVStack {
                        ForEach(_searchResults, id: \.self) { searchResult in
                            HStack {
                                AsyncImage(url: URL(string: _imageUrls[ searchResult ] ?? "https://placehold.co/80")) { image in
                                    image
                                        .resizable  ()
                                        .aspectRatio(contentMode: .fill)
                                        .frame      (width: 50, height: 50)
                                        .clipped    ()
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                }
                                CustomScrollText(text: _names[ searchResult ] ?? "")
                                    .padding(.leading, 20)
                                Spacer()
                            }
                            .padding(.vertical, 5)
                            .onTapGesture {
                                TrackPlayer     .shared.setTrack(searchResult)
                                ControlViewState.shared.showSheet = true
                            }
                            .task {
                                if case nil = _names[ searchResult ] {
                                    let name     = await Track.name    (searchResult)
                                    let imageUrl = await Track.imageUrl(searchResult)

                                    DispatchQueue.main.async {
                                        _names    [ searchResult ] = name
                                        _imageUrls[ searchResult ] = imageUrl
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
                        ForEach(_rss.myRecentSearches(), id: \.self) { term in
                            HStack {
                                Text(term)
                                    .padding(.vertical, 8)
                                Spacer()
                                Button(action: {
                                    _rss.deleteRecentSearch(term)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding     (.horizontal)
                            .background  (Color(.systemBackground))
                            .cornerRadius(8)
                            .onTapGesture {
                                _query = term

                                Task {
                                    if let sr = await Search.tracks(_query) {
                                        _rss.addRecentSearch(_query)
                                        _searchResults = sr
                                        _isSearched    = true
                                    }
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
