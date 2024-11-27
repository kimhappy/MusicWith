//
//  SpotifyArtist.swift
//  MusicWith
//
//  Created by kimhappy on 11/8/24.
//

// https://developer.spotify.com/documentation/web-api/reference/get-an-artist
class SpotifyArtist {
    private var _storage: [String: Any] = [:]
    let artistId: String

    init(artistId: String, name: String? = nil) {
        self.artistId = artistId
        self._storage[ "name" ] = name
    }

    private func load(key: String) async -> Any? {
        if let value = _storage[ key ] {
            return value
        }

        let url = "https://api.spotify.com/v1/artists/\(artistId)"

        guard let json = await SpotifyAPI.shared.getSpotifyAPIJson(url),
              let name = json[ "name" ] as? String else {
            return nil
        }

        _storage = [
            "name": name
        ]

        return _storage[ key ]
    }

    func name() async -> String? {
        return await load(key: "name") as? String
    }
}
