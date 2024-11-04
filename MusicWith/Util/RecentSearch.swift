
import SwiftUI

class RecentSearch : ObservableObject {
    let id   : String
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

    init(id: String) {
        self.id    = id
        self.recentSearch = [
            "example1",
            "example2",
            "example3"
        ]
    }

}
