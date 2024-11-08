//
//  RecentSearch.swift
//  MusicWith
//
//  Created by kimhappy on 10/30/24.
//

import SwiftUI

class RecentSearch : ObservableObject {
    @Published var recentSearch: [String]
    
    func myRecentSearch() -> [String] {
        return recentSearch;
    }
    
    func addRecentSearch(_ term : String) {
        recentSearch.append(term)
    }
    
    func deleteRecentSearch(_ term : String) {
        recentSearch.removeAll{$0 == term}
    }

    init() {
        self.recentSearch = [
            "example1",
            "example2",
            "example3"
        ]
    }

}
