//
//  TrackPlayer.swift
//  MusicWith
//
//  Created by kimhappy on 12/3/24.
//

import AVFAudio
import Player
import QuartzCore

struct PlayerInfo {
    var trackId : String
    var duration: Double // Second
    var now     : Double // Second
}

enum PlayerState {
    case idle
    case playing(PlayerInfo)
    case paused (PlayerInfo)
}

class TrackPlayer: ObservableObject {
    static var shared = TrackPlayer()
    private init() {}

    @Published var state: PlayerState = .idle

    private var _player     : Player?        = nil
    private var _displayLink: CADisplayLink? = nil

    private func _startPlayer(_ trackId: String) -> ()? {
        if _player == nil {
            guard case .fullLoggedIn(let info) = Auth.shared.state else { return nil }

            _player = Player.bootstrap(
                playerListener     : self     ,
                credentialsProvider: info.auth,
                eventSender        : info.eventSender
            )
        }

        _player!.load(MediaProduct(
            productType: ProductType.TRACK,
            productId  : trackId
        ))

        return ()
    }

    private func _stopPlayer() {
        if _player != nil {
            _player!.shutdown()
        }
    }

    public func _startDisplayLink() {
        if _displayLink == nil {
            _displayLink = CADisplayLink(target: self, selector: #selector(_updateTime))
            _displayLink?.add(to: .main, forMode: .default)
        }
    }

    private func _stopDisplayLink() {
        if _displayLink != nil {
            _displayLink!.invalidate()
            _displayLink = nil
        }
    }

    public func setTrack(trackId: String?) -> ()? {
        guard let trackId
        else {
            _stopDisplayLink()
            _stopPlayer()
            state = .idle
            return ()
        }

        let playAfterSet = switch state {
        case .paused: false
        default     : true
        }

        _stopDisplayLink()
        _stopPlayer()
        guard let _ = _startPlayer(trackId) else { return nil }

        let playbackContext = _player!.getActivePlaybackContext()!
        let playState       = PlayerInfo(trackId: trackId, duration: playbackContext.duration, now: 0)
        state               = PlayerState.paused(playState)

        if playAfterSet {
            let _ = play()
        }

        return ()
    }

    @objc private func _updateTime() {
        switch state {
        case .idle:
            return

        case .playing(let playState):
            let ctx = _player!.getActivePlaybackContext()!
            state   = .playing(PlayerInfo(trackId: playState.trackId, duration: ctx.duration, now: ctx.assetPosition))

        case .paused(let playState):
            let ctx = _player!.getActivePlaybackContext()!
            state   = .paused(PlayerInfo(trackId: playState.trackId, duration: ctx.duration, now: ctx.assetPosition))
        }
    }

    public func play() -> ()? {
        guard case .paused(let playState) = state else { return nil }

        _player!.play()
        _startDisplayLink()
        state = .playing(playState)
        return ()
    }

    public func pause() -> ()? {
        guard case .playing(let playState) = state else { return nil }

        _player!.pause()
        _stopDisplayLink()
        state = .paused(playState)
        return ()
    }

    public func toggle() -> ()? {
        switch state {
        case .idle:
            return nil

        case .playing:
            return pause()

        case .paused:
            return play()
        }
    }

    public func seek(_ time: Double) -> ()? {
        if case .idle = state { return nil }
        _player!.seek(time)
        _updateTime()
        return ()
    }

    deinit {
        _player?.shutdown()
        _displayLink?.invalidate()
        _displayLink = nil
    }
}

extension TrackPlayer: PlayerListener {
    public func stateChanged(to state: State) {
        switch state {
        case .IDLE:
            print("IDLE")
            break

        case .PLAYING:
            print("PLAYING")
            break

        case .NOT_PLAYING:
            print("NOT PLAYING")
            break

        case .STALLED:
            print("STALLED")
            break
        }
    }

    public func ended(_ mediaProduct: MediaProduct) {
        print("ENDED")
    }

    public func mediaTransitioned(to mediaProduct: MediaProduct, with playbackContext: PlaybackContext) {
        print("MEDIA TRANSITIONED")
    }

    public func failed(with error: PlayerError) {
        print("ERROR: \(String(describing: error))")
    }

    public func mediaServicesWereReset() {
        print("MEDIA SERVICES WERE RESET")

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(.playback, mode: .default, policy: .longFormAudio)
            try audioSession.setActive(true)
        }
        catch {
            print("ERROR: \(String(describing: error))")
        }
    }
}
