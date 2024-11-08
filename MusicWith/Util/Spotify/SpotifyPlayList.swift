//
//  SpotifyPlayList.swift
//  MusicWith
//
//  Created by kimhappy on 11/6/24.
//

// https://developer.spotify.com/documentation/web-api/reference/get-playlist
// https://developer.spotify.com/documentation/web-api/reference/get-playlists-tracks
class SpotifyPlayList {
    private let CHUNK_SIZE: Int = 10

    private var _storage     : [String: Any ] = [:]
    private var _trackStorage: [SpotifyTrack] = []

    let playListId: String

    init(playListId: String, name: String? = nil, imageUrls: [String]? = nil) {
        self.playListId              = playListId
        self._storage[ "name"      ] = name
        self._storage[ "imageUrls" ] = imageUrls
    }

    private func load(key: String) async -> Any? {
        if let value = _storage[ key ] {
            return value
        }

        let url = "https://api.spotify.com/v1/playlists/\(playListId)"

        guard let json   = await getSpotifyJson(url),
              let images = json[ "images" ] as? [[String: Any]],
              let name   = json[ "name"   ] else {
            return nil
        }

        var imageUrls: [String] = []

        for image in images {
            guard let imageUrl = image[ "url" ] as? String else {
                return nil
            }

            imageUrls.append(imageUrl)
        }

        _storage = [
            "name"     : name,
            "imageUrls": imageUrls
        ]

        return _storage[ key ]
    }

    func name() async -> String? {
        return await load(key: "name") as? String
    }

    func imageUrls() async -> [String]? {
        return await load(key: "imageUrls") as? [String]
    }

    func track(idx: Int) async -> SpotifyTrack? {
        repeat {
            let url = "https://api.spotify.com/v1/playlists/\(playListId)/tracks?offset=\(_trackStorage.count)&limit=\(CHUNK_SIZE)"

            guard let json  = await getSpotifyJson(url)      ,
                  let items = json[ "items" ] as? [[String: Any]],
                  !items.isEmpty else {
                return nil
            }

            for item in items {
                guard let track    = item         [ "track"  ] as?  [String: Any] ,
                      let name     = track        [ "name"   ] as?   String       ,
                      let trackId  = track        [ "id"     ] as?   String       ,
                      let album    = track        [ "album"  ] as?  [String: Any] ,
                      let images   = album        [ "images" ] as? [[String: Any]],
                      let imageUrl = images.first?[ "url"    ] as?   String else {
                    return nil
                }

                _trackStorage.append(SpotifyTrack(trackId: trackId, name: name, imageUrl: imageUrl))
            }
        } while (idx >= _trackStorage.count)

        return _trackStorage[ idx ]
    }
}
