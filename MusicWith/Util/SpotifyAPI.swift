//
//  SpotifyAPI.swift
//  MusicWith
//
//  Created by kimhappy on 11/3/24.
//

import SwiftUI

public struct SpotifyAPI {
    static private func getJson(_ url: String) async -> [String: Any]? {
        let authState = SpotifyAuthState.shared

        guard authState.isLoggedIn,
              let url = URL(string: url) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(authState.accessToken!)", forHTTPHeaderField: "Authorization")

        let data = try? await URLSession.shared.data(for: request).0
        return data.flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any] }
    }

    static private func queryEncode(_ str: String) -> String? {
        return str
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    // https://developer.spotify.com/documentation/web-api/reference/get-current-users-profile
    // https://developer.spotify.com/documentation/web-api/reference/get-users-profile
    // TODO: Test
    static func userInfo(id: String? = nil) async -> SpotifyUserInfo? {
        guard let json   = await getJson("https://api.spotify.com/v1/\(id.map { "users/\($0)" } ?? "me")"),
              let name   = json[ "display_name" ] as? String,
              let images = json[ "images"       ] as? [[String: Any]] else {
            return nil
        }

        let image = images.first?[ "url" ] as? String
        return SpotifyUserInfo(name: name, image: image)
    }

    // https://developer.spotify.com/documentation/web-api/reference/search
    // TODO: Test
    static func search(query: String, limit: Int = 20, offset: Int = 0) async -> [SpotifyPlayListItem]? {
        let url = "https://api.spotify.com/v1/search?q=\(query)&type=track&limit=\(limit)&offset=\(offset)"

        guard let json   = await getJson(url),
              let tracks = json  [ "tracks" ] as?  [String: Any],
              let items  = tracks[ "items"  ] as? [[String: Any]] else {
            return nil
        }

        var results: [SpotifyPlayListItem] = []

        for item in items {
            guard let name   = item         [ "name"   ] as?   String,
                  let songId = item         [ "id"     ] as?   String,
                  let album  = item         [ "album"  ] as?  [String: Any],
                  let images = album        [ "images" ] as? [[String: Any]],
                  let image  = images.first?[ "url"    ] as?   String else {
                return nil
            }

            let result = SpotifyPlayListItem(songId: songId, name: name, image: image)
            results.append(result)
        }

        return results
    }
}
