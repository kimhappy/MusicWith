//
//  SpotifyAPI.swift
//  MusicWith
//
//  Created by kimhappy on 11/3/24.
//

import SwiftUI

public struct SpotifyAPI {
    func userName(callback: @escaping (String?) -> Void) {
        let authState = SpotifyAuthState.shared

        guard authState.isLoggedIn else {
            callback(nil)
            return
        }
        
        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me")!)
        request.setValue("Bearer \(authState.accessToken!)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data                                                                        ,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let name = json["display_name"] as? String                                             ,
                  error == nil else {
                callback(nil)
                return
            }
            
            callback(name)
        }
        .resume()
    }
}
