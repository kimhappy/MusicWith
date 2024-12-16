//
//  Track.swift
//  MusicWith
//
//  Created by kimhappy on 12/3/24.
//

import Foundation

struct Track {
    private static var _storage: [String: Track] = [:]

    public var name    : String
    public var imageUrl: String?
    public var artist  : String?
    public var isrc    : String?
    public var lyrics  : [Lyric]?

    private static func _load< T >(_ id: String, _ get: (Self?) -> T?) async -> T? {
        if let ret = get(_storage[ id ]) {
            return ret
        }

        guard let json       = await Query.getTidalJson("/tracks/\(id)?countryCode=KR&include=artists,albums")  as?  [String: Any] ,
              let data       = json            [ "data"       ]                                                 as?  [String: Any] ,
              let included   = json            [ "included"   ]                                                 as? [[String: Any]],
              let attributes = data            [ "attributes" ]                                                 as?  [String: Any] ,
              let name       = attributes      [ "title"      ]                                                 as?   String       ,
              let isrc       = attributes      [ "isrc"       ]                                                 as?   String       ,
              let artistAttr = included.first(where: { $0[ "type" ] as? String == "artists" })?[ "attributes" ] as?  [String: Any] ,
              let albumAttr  = included.first(where: { $0[ "type" ] as? String == "albums"  })?[ "attributes" ] as?  [String: Any] ,
              let artist     = artistAttr      [ "name"       ]                                                 as?   String       ,
              let imageLinks = albumAttr       [ "imageLinks" ]                                                 as? [[String: Any]],
              let imageUrl   = imageLinks.last?[ "href"       ]                                                 as?   String
        else {
            return nil
        }

        if var track = _storage[ id ] {
            track.imageUrl = imageUrl
            track.artist   = artist
            track.isrc     = isrc
            _storage[ id ] = track
        }
        else {
            _storage[ id ] = Self(name: name, imageUrl: imageUrl, artist: artist, isrc: isrc, lyrics: nil)
        }

        return get(_storage[ id ])
    }

    public static func register(_ id: String, _ newTrack: Track) {
        if var oldTrack = _storage[ id ] {
            if oldTrack.imageUrl == nil, newTrack.imageUrl != nil {
                oldTrack.imageUrl = newTrack.imageUrl
            }

            if oldTrack.artist == nil, newTrack.artist != nil {
                oldTrack.artist = newTrack.artist
            }

            if oldTrack.isrc == nil, newTrack.isrc != nil {
                oldTrack.isrc = newTrack.isrc
            }

            if oldTrack.lyrics == nil, newTrack.lyrics != nil {
                oldTrack.lyrics = newTrack.lyrics
            }

            _storage[ id ] = oldTrack
        }
        else {
            _storage[ id ] = newTrack
        }
    }

    public static func track(_ id: String) async -> Track? {
        return await _load(id) {
            $0
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

    public static func imageUrl(_ id: String) async -> String? {
        return await _load(id) {
            $0?.imageUrl
        }
    }

    public static func isrc(_ id: String) async -> String? {
        return await _load(id) {
            $0?.isrc
        }
    }

    public static func lyrics(_ id: String) async -> [Lyric]? {
        if let ret = _storage[ id ]?.lyrics {
            return ret
        }

        guard let trackIsrc = await isrc(id),
              let json      = await Query.getMwJson("/lyrics?isrc=\(trackIsrc)") as? [[String: Any]]
        else {
            return nil
        }
        
        _storage[ id ]!.lyrics = json.mapOptional {
            switch ($0[ "begin" ] as? Double, $0[ "content" ] as? String) {
            case (.some(let begin), .some(let content)):
                return Lyric(begin: begin, content: content)

            default:
                return nil
            }
        }
        
        return _storage[ id ]!.lyrics
    }
}
