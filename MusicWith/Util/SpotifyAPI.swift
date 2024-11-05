//
//  SpotifyAPI.swift
//  MusicWith
//
//  Created by kimhappy on 11/3/24.
//

import SwiftUI

public struct SpotifyAPI {
    static func userName() async -> String? {
        let authState = SpotifyAuthState.shared
        
        guard authState.isLoggedIn else {
            return nil
        }
        
        let url     = URL(string: "https://api.spotify.com/v1/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(authState.accessToken!)", forHTTPHeaderField: "Authorization")
        
        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let name = json["display_name"] as? String else {
            return nil
        }
        
        return name
    }
}
