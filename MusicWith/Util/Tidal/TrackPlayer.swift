//
//  TrackPlayer.swift
//  MusicWith
//
//  Created by kimhappy on 12/3/24.
//

import AVFAudio
import Player
import QuartzCore
import EventProducer
import Auth

struct PlayerInfo {
    var trackId : String
    var duration: Double
    var now     : Double
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

    private var _trackIds   : [String]       = []
    private var _index      : Int            = 0
    private var _player     : Player?        = nil
    private var _displayLink: CADisplayLink? = nil

    private func _startPlayer(_ trackId: String) -> ()? {
        if _player == nil {
            guard case .loggedIn = Auth.shared.state else { return nil }

            _player = Player.bootstrap(
                playerListener     : self                   ,
                credentialsProvider: TidalAuth       .shared,
                eventSender        : TidalEventSender.shared
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

    public func setTrack(_ trackIds: [String], _ index: Int) -> ()? {
        _stopDisplayLink()
        _stopPlayer()
        _trackIds = trackIds
        _index    = index
        state = PlayerState.paused(PlayerInfo(trackId: _trackIds[ _index ], duration: 0, now: 0))
        _startPlayer(_trackIds[ _index ])!
        play()!
        return ()
    }

    public func prev() -> ()? {
        return setTrack(_trackIds, (_index + _trackIds.count - 1) % _trackIds.count)
    }

    public func next() -> ()? {
        return setTrack(_trackIds, (_index + 1) % _trackIds.count)
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
            _stopDisplayLink()
            state = .playing(PlayerInfo(trackId: info.trackId, duration: info.duration, now: time))
            _player!.seek(time)
            _startDisplayLink()

        case .paused(let info):
            state = .paused(PlayerInfo(trackId: info.trackId, duration: info.duration, now: time))
            _player!.seek(time)
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
        next()
    }
}
