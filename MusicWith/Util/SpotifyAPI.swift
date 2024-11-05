//
//  SpotifyAPI.swift
//  MusicWith
//
//  Created by kimhappy on 11/3/24.
//

import SwiftUI

public struct SpotifyAPI {
    static func userInfo(_ id: String? = nil) async -> UserInfo? {
        let authState = SpotifyAuthState.shared

        guard authState.isLoggedIn,
              let url = URL(string: "https://api.spotify.com/v1/\(id ?? "me")") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(authState.accessToken!)", forHTTPHeaderField: "Authorization")

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json      = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let name      = json[ "display_name" ] as? String,
              let images    = json[ "images"       ] as? [[String: Any]] else {
            return nil
        }

        let image = images.first?[ "url" ] as? String
        return UserInfo(name: name, image: image)
    }
}
