import Foundation

class RecentSearch: ObservableObject {
    static private let _MAX_SEARCH_COUNT = 10
    static private let _DEFAULT_KEY      = "RecentSearches"

    static public var shared = RecentSearch()

    @Published    var _rssList : [String]
    
    private init() {
        _rssList = UserDefaults.standard.stringArray(forKey: Self._DEFAULT_KEY) ?? []
    }

    public func myRecentSearches() -> [String] {
        _rssList
    }

    public func addRecentSearch(_ term: String) {
        var searches = myRecentSearches()

        if let index = searches.firstIndex(of: term) {
            searches.remove(at: index)
        }

        searches.insert(term, at: 0)

        if searches.count > Self._MAX_SEARCH_COUNT {
            searches.removeLast()
        }

        UserDefaults.standard.set(searches, forKey: Self._DEFAULT_KEY)
        _rssList = UserDefaults.standard.stringArray(forKey: Self._DEFAULT_KEY) ?? []
    }

    public func deleteRecentSearch(_ term: String) {
        var searches = myRecentSearches()
        searches.removeAll { $0 == term }
        UserDefaults.standard.set(searches, forKey: Self._DEFAULT_KEY)
        _rssList = UserDefaults.standard.stringArray(forKey: Self._DEFAULT_KEY) ?? []
    }
}
