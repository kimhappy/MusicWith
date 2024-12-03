import Foundation

class RecentSearch : ObservableObject {
    private let maxSearchCount = 10
    private let defaultsKey = "RecentSearches"
    
    // 저장된 검색어 가져오기
    func myRecentSearches() -> [String] {
        UserDefaults.standard.stringArray(forKey: defaultsKey) ?? []
    }
    
    func addRecentSearch(_ term: String) {
        var searches = myRecentSearches()
        if let index = searches.firstIndex(of: term) {
            searches.remove(at: index)
        }
        searches.insert(term, at: 0)
        if searches.count > maxSearchCount {
            searches.removeLast()
        }
        UserDefaults.standard.set(searches, forKey: defaultsKey)
    }
    
    func deleteRecentSearch(_ term: String) {
        var searches = myRecentSearches()
        searches.removeAll { $0 == term }
        UserDefaults.standard.set(searches, forKey: defaultsKey)
    }
}
