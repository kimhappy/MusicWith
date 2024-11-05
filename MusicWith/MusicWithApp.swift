//
//  MusicWithApp.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

import SwiftUI

@main
struct MusicWithApp: App {
    @StateObject private var authState = SpotifyAuthState.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .onOpenURL { url in
                    authState.handleRedirect(url)
                }
        }
    }
}
