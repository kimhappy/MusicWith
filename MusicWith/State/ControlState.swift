//
//  ControlState.swift
//  MusicWith
//
//  Created by kimhappy on 10/30/24.
//

import SwiftUI
import AVFoundation

class ControlState: ObservableObject {
    static var shared = ControlState()
    private init() {}
    
    private var player: AVPlayer?
    
    //added
    private var timeObserver : Any?
    
    
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
        
        guard let player    else { return }
        guard let playState else { return }
        
        
        playState.isPlaying = true;
        playState.now = 0.0
        
        getDuration()
        setNow()
        
        player.play()
        
    }
    
    // added functions
    private func getDuration() {
        guard let player    else { return }
        guard let playState else { return }
        
        if let duration = player.currentItem?.asset.duration {
            playState.duration = CMTimeGetSeconds(duration)
        }
        
    }
    
    // Slow?
    private func setNow() {
        guard let player    else { return }
        guard let playState else { return }
        
        
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            //guard let self = self else { return }
            //guard let playState = self.playState else { return }
            playState.now = CMTimeGetSeconds(time)
                    
            // 음악이 끝나면 일시정지 상태로 변경
            if playState.now >= playState.duration {
                    playState.isPlaying = false
                    player.seek(to: .zero)
                }
            }
         
         
    }
    
    

    deinit {
        stopPlayback()
        showSheet = false
    }
}
