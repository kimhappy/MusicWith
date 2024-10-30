//
//  ControlState.swift
//  MusicWith
//
//  Created by kimhappy on 10/30/24.
//

import SwiftUI
import AVFoundation

class ControlState: ObservableObject {
    private var player: AVPlayer?

    @Published var playState: PlayState? = nil
    @Published var showSheet: Bool       = false {
        didSet {
            if !showSheet {
                stopPlayback()
            }
        }
    }

    func setSong(song: Song) -> Bool {
        guard let url = URL(string: song.url) else { return false }
        showSheet     = true
        stopPlayback()
        startPlayback(song: song, url: url)
        return true
    }

    func togglePlaying() {
        guard let player    else { return }
        guard let playState else { return }
        
        if playState.isPlaying {
            player.pause()
        }
        else {
            player.play()
        }
    }

    private func stopPlayback() {
        player?.pause()
        player    = nil
        playState = nil
        // TODO: Implement
    }

    private func startPlayback(song: Song, url: URL) {
        player    = AVPlayer(url: url)
        playState = PlayState(song: song)
        player?.play()
        // TODO: Implement
    }

    deinit {
        stopPlayback()
        showSheet = false
    }
}
