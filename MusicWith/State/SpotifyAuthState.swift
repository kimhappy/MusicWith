//
//  AuthState.swift
//  MusicWith
//
//  Created by kimhappy on 11/3/24.
//

import SwiftUI

// TODO: Save token and session id into the safe storage
class SpotifyAuthState: ObservableObject {
    static var shared = SpotifyAuthState()
    private init() {}

    @Published var isLoggedIn = false

    var state      : String?
    var accessToken: String?
    var sessionId  : String?

    func login() {
        state         = UUID().uuidString
        guard let url = URL(string: "http://localhost:8000/login?state=\(state!)") else { return }
        UIApplication.shared.open(url)
    }

    func logout() {
        isLoggedIn  = false
        state       = nil
        accessToken = nil
        sessionId   = nil
    }

    func handleRedirect(_ url: URL) async {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }

        var responseCode : String? = nil
        var responseState: String? = nil

        for item in queryItems {
            if item.name == "code" {
                responseCode = item.value
            }
            else if item.name == "state" {
                responseState = item.value
            }
        }

        guard let rc = responseCode ,
              let rs = responseState,
              rs == state else { return }

        guard let url      = URL(string: "http://localhost:8000/token") else { return }
        var request        = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody    = ["code": rc]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        request.httpBody   = jsonData

        let data = try? await URLSession.shared.data(for: request).0
        let json = data.flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any] }

        guard let accessToken = json?[ "access_token" ] as? String,
              let sessionId   = json?[ "session_id"   ] as? String else { return }

        DispatchQueue.main.async {
            self.isLoggedIn  = true
            self.state       = nil
            self.accessToken = accessToken
            self.sessionId   = sessionId
        }
    }
}
