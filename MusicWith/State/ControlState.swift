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
    @Published var isDragging = false // slider dragging 추적
    @Published var playlist : PlayList? // playlist 존재 여부 확인
    @Published var musicIndex : Int? // playlist 존재시 현재 음악의 index
    
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
        self.stateSynchronization()
    }

    private func stopPlayback() {
        player?.pause()
        player    = nil
        playState = nil
        // TODO: Implement
        playlist    = nil
        musicIndex  = nil
    }

    private func startPlayback(song: Song, url: URL) {
        player    = AVPlayer(url: url)
        playState = PlayState(song: song)
       
        
        // TODO: Implement
        guard let player    else { return }
        guard let playState else { return }
        
        
        playState.isPlaying = true;
        playState.now = 0.0;
        
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
        
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            //guard let self = self else { return }
            //guard let playState = self.playState else { return }
            if self.isDragging == true {return } // slider dragging 도중에는 now 갱신 안하도록
            playState.now = CMTimeGetSeconds(time)
            
            self.stateSynchronization()
            
            // 음악이 끝나면 일시정지 상태로 변경
            if playState.now >= playState.duration {
                playState.isPlaying = false
                player.seek(to: .zero)
                player.pause()
            }
        }
    }
    
    func seek(_ time : Double) {
        guard let player    else { return }
        guard let playState else { return }
        
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: targetTime)
        stateSynchronization()
    }
    
    private func stateSynchronization() {
        let newplayState = playState
        self.playState = newplayState
        
    }
    
    func setPlaylist(_ list : PlayList, _ song : Song) {
        self.playlist = list;
        
    }
    
    func setMusicIndex(_ list : PlayList, _ song : Song) {
        self.musicIndex = list.songs.firstIndex(where:  {
            $0.id == song.id
        })
    }
    
    // playlist 없거나 song이 1개인 경우 자기 자신 재생하도록?
    func playNext(){
        // 노래 중단된 경우
        guard let player else { return }
        guard let playState else { return }
        
        // playlist 없을 시 자기 자신 재생
        guard let playlist = self.playlist else {
            setSong(song: playState.song)
            return
        }
        
        // list 있는데 music index 없는 경우
        guard let musicIndex = self.musicIndex else { return } // error
        
        // list 에 song 이 0개인 경우
        if playlist.songs.count == 0 {return }
        
        // playlist 의 maxIndex
        let maxIndex = playlist.songs.count - 1

        var newIndex : Int
        if maxIndex <= musicIndex {
            newIndex = 0
        }
        else {
            newIndex = musicIndex + 1
        }
        
    
        let newSong = playlist.songs[newIndex]
        
        
        setSong(song: newSong)
        setPlaylist(playlist, newSong)
        self.musicIndex = newIndex
        stateSynchronization()
    }
    
    func playPrev() {
        // 노래 중단된 경우
        guard let player else { return }
        guard let playState else { return }
        
        // playlist 없을 시 자기 자신 재생
        guard let playlist = self.playlist else {
            setSong(song: playState.song)
            return
        }
        
        // list 있는데 music index 없는 경우
        guard let musicIndex = self.musicIndex else { return } // error
        
        // list 에 song 이 0개인 경우
        if playlist.songs.count == 0 {return }
        
        // playlist 의 maxIndex
        let maxIndex = playlist.songs.count - 1
    
        var newIndex : Int
        if musicIndex <= 0 {
            newIndex = maxIndex
        }
        else {
            newIndex = musicIndex - 1
        }
        
    
        let newSong = playlist.songs[newIndex]
        
        setSong(song: newSong)
        setPlaylist(playlist, newSong)
        self.musicIndex = newIndex
        stateSynchronization()
    }

    deinit {
        stopPlayback()
        showSheet = false
    }
}
