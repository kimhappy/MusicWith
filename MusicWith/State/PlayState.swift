//
//  PlayState.swift
//  MusicWith
//
//  Created by kimhappy on 10/30/24.
//

import SwiftUI

class PlayState {
    var song     : Song
    var isPlaying: Bool
    var duration : Double
    var now      : Double

    init(song: Song) {
        self.song      = song
        self.isPlaying = false
        self.duration  = 123
        self.now       = 23
    }
}
