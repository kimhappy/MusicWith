//
//  SpotifyAPI.swift
//  MusicWith
//
//  Created by kimhappy on 11/3/24.
//

import SwiftUI
import KeychainSwift

class SpotifyAPI: ObservableObject {
    static var shared = SpotifyAPI()

    @Published var isLoggedIn = false

    private let keychain = KeychainSwift(keyPrefix: "com.kimhappy.musicwith.")
    private var state      : String?
    private var accessToken: String? {
        didSet {
            if let token = accessToken {
                keychain.set(token, forKey: "accessToken")
            }
            else {
                keychain.delete("accessToken")
            }
        }
    }
    private var sessionId: String? {
        didSet {
            if let id = sessionId {
                keychain.set(id, forKey: "sessionId")
            }
            else {
                keychain.delete("sessionId")
            }
        }
    }

    private init() {
        sessionId   = keychain.get("sessionId"  )
        accessToken = keychain.get("accessToken")

        if sessionId != nil && accessToken != nil {
            isLoggedIn = true

            Task {
                await tokenRefresh()
            }
        }
        else {
            sessionId   = nil
            accessToken = nil
        }
    }

    private static func getTokenJson(body: [String: String]) async -> [String: Any]? {
        guard let url      = URL(string: "http://localhost:8000/token") else { return nil }
        var request        = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return nil }
        request.httpBody   = jsonData

        let data = try? await URLSession.shared.data(for: request).0
        return data.flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any] }
    }

    private func fetchWithAuth(_ url: URL) async -> [String: Any]? {
        guard let accessToken else { return nil }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let data = try? await URLSession.shared.data(for: request).0
        return data.flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any] }
    }

    func getSpotifyAPIJson(_ url: String) async -> [String: Any]? {
        guard isLoggedIn,
              let url = URL(string: url) else {
            return nil
        }

        if let result = await fetchWithAuth(url) {
            return result
        }
        else {
            await tokenRefresh()
            return await fetchWithAuth(url)
        }
    }

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
              let queryItems = components.queryItems else { return }

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

        let requestBody = ["code": rc]

        guard let json        = await SpotifyAPI.getTokenJson(body: requestBody),
              let accessToken = json[ "access_token" ] as? String,
              let sessionId   = json[ "session_id"   ] as? String else { return }

        DispatchQueue.main.async {
            self.isLoggedIn  = true
            self.accessToken = accessToken
            self.sessionId   = sessionId
        }
    }

    func tokenRefresh() async {
        guard let sessionId else {
            DispatchQueue.main.async {
                self.logout()
                self.login ()
            }

            return
        }

        let requestBody = ["session_id": sessionId]

        guard let json        = await SpotifyAPI.getTokenJson(body: requestBody),
              let accessToken = json[ "access_token" ] as? String else {
            DispatchQueue.main.async {
                self.logout()
                self.login ()
            }

            return
        }

        DispatchQueue.main.async {
            self.accessToken = accessToken
        }
    }
}
