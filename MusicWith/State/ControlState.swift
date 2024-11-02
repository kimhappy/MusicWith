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
                sheetHeight = .mini
            }
        }
    }
    @Published var sheetHeight: SheetHeight = .mini
    
    
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
            playState.isPlaying = false
        }
        else {
            player.play()
            playState.isPlaying = true
        }
    }

    private func stopPlayback() {
        player?.pause()
        player    = nil
        playState = nil
        // TODO: Implement
        // pause is right?
        
    }

    private func startPlayback(song: Song, url: URL) {
        player    = AVPlayer(url: url)
        playState = PlayState(song: song)
       
        
        // TODO: Implement
        // current tim
        guard let player    else { return }
        guard let playState else { return }
        // print(player, playState.song)
        playState.isPlaying = true;
        
        getDuration()
        setNow()
        
        player.play()
        print(playState.duration)
        
    }
    
    // added functions
    private func getDuration() {
        guard let player    else { return }
        guard let playState else { return }
        
       
        
        if let duration = player.currentItem?.asset.duration {
            playState.duration = CMTimeGetSeconds(duration)
        }
        
    }
    
    private func setNow() {
        guard let player    else { return }
        guard let playState else { return }
        
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            
        
    }
    
    

    deinit {
        stopPlayback()
        showSheet = false
    }
}
