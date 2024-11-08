//
//  SpotifyAPI.swift
//  MusicWith
//
//  Created by kimhappy on 11/3/24.
//

import SwiftUI

func getSpotifyJson(_ url: String) async -> [String: Any]? {
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
