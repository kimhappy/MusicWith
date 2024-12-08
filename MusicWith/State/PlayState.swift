//
//  PlayState.swift
//  MusicWith
//
//  Created by kimhappy on 10/30/24.
//

import SwiftUI

class PlayState {
    var song     : SpotifyTrack
    var isPlaying: Bool
    var duration : Double
    var now      : Double

    init(song: SpotifyTrack) {
        self.song      = song
        self.isPlaying = false
        self.duration  = 0
        self.now       = 0
    }
}
