//
//  AuthState.swift
//  MusicWith
//
//  Created by kimhappy on 11/3/24.
//

import SwiftUI

// TODO: Token Refresh
// TODO: Save tokens into the safe storage
class SpotifyAuthState: ObservableObject {
    static var shared = SpotifyAuthState()
    private init() {}

    @Published var isLoggedIn = false
    @Published var userName   = ""

    var accessToken : String?
    var refreshToken: String?

    func login() {
        guard let url = URL(string: "http://localhost:8000/login") else { return }
        UIApplication.shared.open(url)
    }

    func logout() {
        isLoggedIn   = false
        userName     = ""
        accessToken  = nil
        refreshToken = nil
    }

    func handleRedirect(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }

        for item in queryItems {
            if item.name == "access_token" {
                accessToken = item.value
            }
            else if item.name == "refresh_token" {
                refreshToken = item.value
            }
        }

        if accessToken != nil && refreshToken != nil {
            isLoggedIn = true
        }
        else {
            accessToken  = nil
            refreshToken = nil
        }
    }
}
