//
//  SpotifySearch.swift
//  MusicWith
//
//  Created by kimhappy on 11/8/24.
//

// https://developer.spotify.com/documentation/web-api/reference/search
class SpotifySearch {
    let query: String

    private let CHUNK_SIZE: Int = 10

    private var _trackStorage: [SpotifyTrack] = []

    private static func queryEncode(_ str: String) -> String? {
        return str
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    init(query: String) {
        self.query = query
    }

    func track(idx: Int) async -> SpotifyTrack? {
        repeat {
            let url = "https://api.spotify.com/v1/search?q=\(query)&type=track&offset=\(_trackStorage.count)&limit=\(CHUNK_SIZE)"

            guard let json   = await getSpotifyJson(url),
                  let tracks = json  [ "tracks" ] as?  [String: Any],
                  let items  = tracks[ "items"  ] as? [[String: Any]] else {
                return nil
            }

            for item in items {
                guard let trackId  = item         [ "id"     ] as?   String       ,
                      let name     = item         [ "name"   ] as?   String       ,
                      let album    = item         [ "album"  ] as?  [String: Any] ,
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
