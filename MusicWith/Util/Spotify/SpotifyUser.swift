//
//  SpotifyUser.swift
//  MusicWith
//
//  Created by kimhappy on 11/5/24.
//

// https://developer.spotify.com/documentation/web-api/reference/get-current-users-profile
// https://developer.spotify.com/documentation/web-api/reference/get-users-profile
// https://developer.spotify.com/documentation/web-api/reference/get-a-list-of-current-users-playlists
// https://developer.spotify.com/documentation/web-api/reference/get-list-users-playlists
class SpotifyUser {
    private let CHUNK_SIZE: Int = 10

    private var _storage        : [String: Any    ] = [:]
    private var _playListStorage: [SpotifyPlayList] = []

    let userId: String?

    init(userId: String?, name: String? = nil, imageUrl: String? = nil) {
        self.userId                 = userId
        self._storage[ "name"     ] = name
        self._storage[ "imageUrl" ] = imageUrl
    }

    private func load(key: String) async -> Any? {
        if let value = _storage[ key ] {
            return value
        }

        guard let json   = await getSpotifyJson("https://api.spotify.com/v1/\(userId.map { "users/\($0)" } ?? "me")"),
              let name   = json[ "display_name" ] as?   String,
              let images = json[ "images"       ] as? [[String: Any]] else {
            return nil
        }

        let imageUrl = images.first?[ "url" ] as? String ?? ""

        _storage = [
            "name"    : name,
            "imageUrl": imageUrl
        ]

        return _storage[ key ]
    }

    func name() async -> String? {
        return await load(key: "name") as? String
    }

    func imageUrl() async -> String? {
        return await load(key: "imageUrl") as? String
    }

    func playList(idx: Int) async -> SpotifyPlayList? {
        repeat {
            guard let json  = await getSpotifyJson("https://api.spotify.com/v1/\(userId.map { "users/\($0)" } ?? "me")/playlists?offset=\(_playListStorage.count)&limit=\(CHUNK_SIZE)"),
                  let items = json[ "items" ] as? [[String: Any]] else {
                return nil
            }

            for item in items {
                guard let playListId = item[ "id"     ] as?   String,
                      let name       = item[ "name"   ] as?   String,
                      let images     = item[ "images" ] as? [[String: Any]] else {
                    return nil
                }

                var imageUrls: [String] = []

                for image in images {
                    guard let url = image[ "url" ] as? String else {
                        return nil
                    }

                    imageUrls.append(url)
                }

                _playListStorage.append(SpotifyPlayList(playListId: playListId, name: name, imageUrls: imageUrls))
            }
        } while (idx >= _playListStorage.count)

        return _playListStorage[ idx ]
    }
}
