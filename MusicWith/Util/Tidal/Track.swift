//
//  Track.swift
//  MusicWith
//
//  Created by kimhappy on 12/3/24.
//

import Foundation

struct Track {
    private static var _storage: [String: Track] = [:]

    public var name  : String  // Track name
    public var image : String? // Album art URL
    public var artist: String? // Artist name
    public var isrc  : String?
    public var lyrics: String?

    private static func _load< T >(_ id: String, _ get: (Self?) -> T?) async -> T? {
        if let ret = get(_storage[ id ]) {
            return ret
        }

        guard let url        = URL(string: "https://openapi.tidal.com/v2/tracks/\(id)?countryCode=KR&include=artists,albums"),
              let json       = await Query.getTidalJson(url),
              let data       = json            [ "data"       ] as?  [String: Any] ,
              let included   = json            [ "included"   ] as? [[String: Any]],
              let attributes = data            [ "attributes" ] as?  [String: Any] ,
              let name       = attributes      [ "title"      ] as?   String       ,
              let isrc       = attributes      [ "isrc"       ] as?   String       ,
              let artistAttr = included.first(where: { $0[ "type" ] as? String == "artists" })?[ "attributes" ] as? [String: Any],
              let albumAttr  = included.first(where: { $0[ "type" ] as? String == "albums"  })?[ "attributes" ] as? [String: Any],
              let artist     = artistAttr      [ "name"       ] as?   String       ,
              let imageLinks = albumAttr       [ "imageLinks" ] as? [[String: Any]],
              let image      = imageLinks.last?[ "href"       ] as?   String
        else {
            return nil
        }

        if let track = _storage[ id ] {
            _storage[ id ]!.image  = image
            _storage[ id ]!.artist = artist
            _storage[ id ]!.isrc   = isrc
        }
        else {
            _storage[ id ] = Self(name: name, image: image, artist: artist, isrc: isrc, lyrics: nil)
        }

        return get(_storage[ id ])
    }

    public static func register(_ id: String, _ newTrack: Track) {
        if let oldTrack = _storage[ id ] {
            if oldTrack.image == nil, newTrack.image != nil {
                _storage[ id ]!.image = newTrack.image
            }

            if oldTrack.artist == nil, newTrack.artist != nil {
                _storage[ id ]!.artist = newTrack.artist
            }

            if oldTrack.isrc == nil, newTrack.isrc != nil {
                _storage[ id ]!.isrc = newTrack.isrc
            }

            if oldTrack.lyrics == nil, newTrack.lyrics != nil {
                _storage[ id ]!.lyrics = newTrack.lyrics
            }
        }
        else {
            _storage[ id ] = newTrack
        }
    }

    public static func name(_ id: String) async -> String? {
        return await _load(id) {
            $0?.name
        }
    }

    public static func artist(_ id: String) async -> String? {
        return await _load(id) {
            $0?.artist
        }
    }

    public static func image(_ id: String) async -> String? {
        return await _load(id) {
            $0?.image
        }
    }

    public static func isrc(_ id: String) async -> String? {
        return await _load(id) {
            $0?.isrc
        }
    }

    public static func lyrics(_ id: String) async -> String? {
        // TODO: Implement
        return "TEST LYRICS 0\nTEST LYRICS 1\nTEST LYRICS 2"
    }
}
