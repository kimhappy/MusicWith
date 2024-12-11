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
    static public var shared = TrackPlayer()
    private init() {}

    @Published var state: PlayerState = .idle

    private var _player     : Player?        = nil
    private var _displayLink: CADisplayLink? = nil

    private func _startPlayer(_ trackId: String) -> ()? {
        if _player == nil {
            guard case .loggedIn(let info) = Auth.shared.state else { return nil }

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
        _player?.shutdown()
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

    @objc private func _updateTime() {
        guard let ctx = _player?.getActivePlaybackContext() else { return }

        switch state {
        case .idle:
            return

        case .playing(let info):
            state = .playing(PlayerInfo(trackId: info.trackId, duration: ctx.duration, now: ctx.assetPosition))

        case .paused(let info):
            state = .paused(PlayerInfo(trackId: info.trackId, duration: ctx.duration, now: ctx.assetPosition))
        }
    }

    public func setTrack(_ trackId: String?) -> ()? {
        _stopDisplayLink()
        _stopPlayer()

        guard let trackId
        else {
            state = .idle
            return ()
        }

        _startPlayer(trackId)!
        state = PlayerState.paused(PlayerInfo(trackId: trackId, duration: 0, now: 0))
        play()!
        return ()
    }

    public func play() -> ()? {
        guard case .paused(let info) = state else { return nil }
        _player!.play()
        _startDisplayLink()
        state = .playing(info)
        return ()
    }

    public func pause() -> ()? {
        guard case .playing(let info) = state else { return nil }
        _player!.pause()
        _stopDisplayLink()
        state = .paused(info)
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
        switch state {
        case .idle:
            return nil

        case .playing(let info):
            _player!.seek(time)
            state = .playing(PlayerInfo(trackId: info.trackId, duration: info.duration, now: time))

        case .paused(let info):
            _player!.seek(time)
            state = .paused(PlayerInfo(trackId: info.trackId, duration: info.duration, now: time))
        }

        return ()
    }

    public func info() -> PlayerInfo? {
        switch state {
        case .idle:
            return nil

        case .playing(let info):
            return info

        case .paused(let info):
            return info
        }
    }

    deinit {
        _stopPlayer()
        _stopDisplayLink()
    }
}

extension TrackPlayer: PlayerListener {
    public func stateChanged          (to state: State) {}
    public func mediaTransitioned     (to mediaProduct: MediaProduct, with playbackContext: PlaybackContext) {}
    public func failed                (with error: PlayerError) {}
    public func mediaServicesWereReset() {}

    public func ended(_ mediaProduct: MediaProduct) {
        pause()
    }
}
