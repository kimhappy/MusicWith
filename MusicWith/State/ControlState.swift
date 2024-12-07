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

    private var player      : AVPlayer?         = nil
    private var timeObserver: Any?              = nil
    private var endObserver : NSObjectProtocol? = nil

    @Published var playState: PlayState? = nil
    @Published var showSheet: Bool       = false {
        didSet {
            if !showSheet {
                stopPlayback()
                sheetHeight = .mini
            }
        }
    }
    @Published var sheetHeight: SheetHeight         = .mini
    @Published var isDragging                       = false // slider dragging 추적
    @Published var playlist   : SpotifyPlayList?    = nil   // playlist 존재 여부 확인
    @Published var musicIndex : Int?                = nil   // playlist 존재시 현재 음악의 index

    func setSong(song : SpotifyTrack) async -> Bool {
        guard let url = await URL(string: "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3") else { return false }
        showSheet     = true
        stopPlayback()
        startPlayback(song: song, url: url)
        return true
    }

    func togglePlaying() {
        guard let player, let playState else { return }

        if playState.isPlaying {
            player.pause()
            playState.isPlaying = false
        }
        else {
            player.play()
            playState.isPlaying = true
        }

        stateSynchronization()
    }

    private func stopPlayback() {
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }

        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }

        player?.pause()
        player       = nil
        timeObserver = nil
        endObserver  = nil
        playState    = nil
        playlist     = nil
        musicIndex   = nil
    }

    private func startPlayback(song: SpotifyTrack, url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player         = AVPlayer(playerItem: playerItem)
        playState      = PlayState(song: song)

        guard let player, let playState else { return }

        playState.isPlaying = true
        playState.now       = 0.0

        guard let duration = player.currentItem?.asset.duration else { return }
        playState.duration = CMTimeGetSeconds(duration)

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue      : .main) { time in
            if self.isDragging { return } // slider dragging 도중에는 now 갱신 안하도록
            playState.now = CMTimeGetSeconds(time)
            self.stateSynchronization()
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object : playerItem,
            queue  : .main) { _ in
                playState.isPlaying = false
                player.seek(to: .zero)
                player.pause()
                self.stateSynchronization()
            }

        player.play()
    }

    func seek(_ time: Double) {
        guard let player, let playState else { return }
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: targetTime)
        stateSynchronization()
    }

    private func stateSynchronization() {
        let newplayState = playState
        self.playState   = newplayState
    }

    func setPlaylist(_ list: SpotifyPlayList, _ song: SpotifyTrack) {
        self.playlist = list;
    }

    func setMusicIndex(_ list: SpotifyPlayList, _ song: SpotifyTrack) async {
        self.musicIndex = await list.track(idx: list.total()).firstIndex(where:  {
            $0.trackId == song.trackId
        })
    }

    // playlist 없거나 song이 1개인 경우 자기 자신 재생하도록?
    func playNext() async {
        // 노래 중단된 경우
        guard let player, let playState else { return }

        // playlist 없을 시 자기 자신 재생
        guard let playlist = self.playlist else {
            await setSong(song: playState.song)
            return
        }

        // list 있는데 music index 없는 경우
        // list 에 song이 0개인 경우
        guard let musicIndex, playlist.total() != 0 else { return } // error
        let newIndex = (musicIndex + 1) % playlist.total()
        let newSong  = await playlist.track(idx: -1)[ newIndex ]

        await setSong(song: newSong)
        setPlaylist(playlist, newSong)
        self.musicIndex = newIndex
        stateSynchronization()
    }

    func playPrev() async {
        // 노래 중단된 경우
        guard let player, let playState else { return }

        // playlist 없을 시 자기 자신 재생
        guard let playlist else {
            await setSong(song: playState.song)
            return
        }

        // list 있는데 music index 없는 경우
        // list 에 song이 0개인 경우
        guard let musicIndex, playlist.total() != 0 else { return } // error

        let newIndex = (musicIndex - 1 + playlist.total()) % playlist.total()
        let newSong  = await playlist.track(idx: -1)[newIndex]

        await setSong(song: newSong)
        setPlaylist(playlist, newSong)
        self.musicIndex = newIndex
        stateSynchronization()
    }

    deinit {
        stopPlayback()
        showSheet = false
    }
}
