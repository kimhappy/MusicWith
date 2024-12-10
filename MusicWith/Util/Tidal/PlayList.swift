//
//  PlayList.swift
//  MusicWith
//
//  Created by kimhappy on 12/5/24.
//

import Foundation

// TODO: Paging
struct PlayList {
    private static var _storage: [String: PlayList] = [:]

    public var name  :  String
    public var image :  String
    public var tracks: [String]

    public static func myPlayListIds() async -> [String]? {
        guard let url      = URL(string: "https://openapi.tidal.com/v2/playlists/me?include=items.albums,items.artists"),
              let json     = await Query.getTidalJson(url),
              let data     = json[ "data"     ] as? [[String: Any]],
              let included = json[ "included" ] as? [[String: Any]]
        else {
            return nil
        }

        var ids: [String] = []

        for item in data {
            guard let id            = item             [ "id"            ] as?   String       ,
                  let attributes    = item             [ "attributes"    ] as?  [String: Any] ,
                  let relationships = item             [ "relationships" ] as?  [String: Any] ,
                  let name          = attributes       [ "name"          ] as?   String       ,
                  let imageLinks    = attributes       [ "imageLinks"    ] as? [[String: Any]],
                  let image         = imageLinks.first?[ "href"          ] as?   String       ,
                  let items         = relationships    [ "items"         ] as?  [String: Any] ,
                  let itemsData     = items            [ "data"          ] as? [[String: Any]],
                  let tracks        = itemsData.mapOptional({ $0[ "id" ] as? String })
            else {
                return nil
            }

            ids.append(id)
            _storage[ id ] = PlayList(name: name, image: image, tracks: tracks)
        }

        // TODO: to struct
        var tracks : [        [String]] = [ ] // id, name, isrc, artistId, albumId
        var artists: [String:  String ] = [:] // artistId -> name
        var images : [String:  String ] = [:] // albumId -> image

        for item in included {
            guard let type          = item[ "type"          ] as?  String      ,
                  let id            = item[ "id"            ] as?  String      ,
                  let attributes    = item[ "attributes"    ] as? [String: Any],
                  let relationships = item[ "relationships" ] as? [String: Any]
            else {
                return nil
            }

            if type == "tracks",
               let trackName       = attributes            [ "title"   ] as?   String       ,
               let trackIsrc       = attributes            [ "isrc"    ] as?   String       ,
               let trackArtist     = relationships         [ "artists" ] as?  [String: Any] ,
               let trackAlbum      = relationships         [ "albums"  ] as?  [String: Any] ,
               let trackArtistData = trackArtist           [ "data"    ] as? [[String: Any]],
               let trackAlbumData  = trackAlbum            [ "data"    ] as? [[String: Any]],
               let trackArtistId   = trackArtistData.first?[ "id"      ] as?   String       ,
               let trackAlbumId    = trackAlbumData .first?[ "id"      ] as?   String {
                tracks.append([id, trackName, trackIsrc, trackArtistId, trackAlbumId])
            }
            else if type == "artists",
                    let name = attributes[ "name" ] as? String {
                artists[ id ] = name
            }
            else if type == "albums",
                    let imageLinks = attributes      [ "imageLinks" ] as? [[String: Any]],
                    let image      = imageLinks.last?[ "href"       ] as?   String {
                images[ id ] = image
            }
            else {
                return nil
            }
        }

        for track in tracks {
            let id       = track  [ 0        ]
            let name     = track  [ 1        ]
            let isrc     = track  [ 2        ]
            let artistId = track  [ 3        ]
            let albumId  = track  [ 4        ]
            let artist   = artists[ artistId ]
            let image    = images [ albumId  ]
            Track.register(id, Track(name: name, image: image, artist: artist, isrc: isrc))
        }

        return ids
    }

    private static func _load< T >(_ id: String, _ get: (Self?) -> T?) async -> T? {
        if let ret = get(_storage[ id ]) {
            return ret
        }

        guard let url        = URL(string: "https://openapi.tidal.com/v2/playlists/\(id)?countryCode=KR&include=items"),
              let json       = await Query.getTidalJson(url),
              let data       = json             [ "data"       ] as?  [String: Any] ,
              let included   = json             [ "included"   ] as? [[String: Any]],
              let attributes = data             [ "attributes" ] as?  [String: Any] ,
              let name       = attributes       [ "name"       ] as?   String       ,
              let imageLinks = attributes       [ "imageLinks" ] as? [[String: Any]],
              let image      = imageLinks.first?[ "href"       ] as?   String
        else {
            return nil
        }

        var tracks: [String] = []

        for item in included {
            if let trackId         = item                 [ "id"         ] as?   String       ,
               let trackAttributes = item                 [ "attributes" ] as?  [String: Any] ,
               let trackName       = trackAttributes      [ "title"      ] as?   String       ,
               let trackIsrc       = trackAttributes      [ "isrc"       ] as?   String       ,
               let trackImageLinks = trackAttributes      [ "imageLinks" ] as? [[String: Any]],
               let trackImage      = trackImageLinks.last?[ "href"       ] as?   String {
                tracks.append(trackId)
                Track.register(trackId, Track(name: trackName, image: trackImage, isrc: trackIsrc))
            }
        }

        _storage[ id ] = PlayList(name: name, image: image, tracks: tracks)
        return get(_storage[ id ])
    }

    public static func name(_ id: String) async -> String? {
        return await _load(id) {
            $0?.name
        }
    }

    public static func image(_ id: String) async -> String? {
        return await _load(id) {
            $0?.image
        }
    }

    public static func tracks(_ id: String) async -> [String]? {
        return await _load(id) {
            $0?.tracks
        }
    }
}
