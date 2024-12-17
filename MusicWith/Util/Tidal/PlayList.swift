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

    public var name    :  String
    public var imageUrl:  String
    public var trackIds: [String]

    public static func myPlayListIds() async -> [String]? {
        guard let json     = await Query.getTidalJson("/playlists/me?include=items.albums,items.artists") as?  [String: Any] ,
              let data     = json[ "data"     ]                                                           as? [[String: Any]],
              let included = json[ "included" ]                                                           as? [[String: Any]]
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
                  let imageUrl      = imageLinks.first?[ "href"          ] as?   String       ,
                  let items         = relationships    [ "items"         ] as?  [String: Any] ,
                  let itemsData     = items            [ "data"          ] as? [[String: Any]],
                  let trackIds      = itemsData.mapOptional({ $0[ "id" ] as? String })
            else {
                return nil
            }

            ids.append(id)
            _storage[ id ] = PlayList(name: name, imageUrl: imageUrl, trackIds: trackIds)
        }

        // TODO: to struct
        var tracks   : [        [String]] = [ ] // id, name, isrc, artistId, albumId
        var artists  : [String:  String ] = [:] // artistId -> name
        var imageUrls: [String:  String ] = [:] // albumId -> image

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
                imageUrls[ id ] = image
            }
            else {
                return nil
            }
        }

        for track in tracks {
            let id       = track    [ 0        ]
            let name     = track    [ 1        ]
            let isrc     = track    [ 2        ]
            let artistId = track    [ 3        ]
            let albumId  = track    [ 4        ]
            let artist   = artists  [ artistId ]
            let imageUrl = imageUrls[ albumId  ]
            Track.register(id, Track(name: name, imageUrl: imageUrl, artist: artist, isrc: isrc))
        }

        return ids
    }

    private static func _load< T >(_ id: String, _ get: (Self?) -> T?) async -> T? {
        if let ret = get(_storage[ id ]) {
            return ret
        }

        guard let json       = await Query.getTidalJson("/playlists/\(id)?countryCode=KR&include=items") as? [String: Any],
              let data       = json             [ "data"       ]                                         as?  [String: Any] ,
              let included   = json             [ "included"   ]                                         as? [[String: Any]],
              let attributes = data             [ "attributes" ]                                         as?  [String: Any] ,
              let name       = attributes       [ "name"       ]                                         as?   String       ,
              let imageLinks = attributes       [ "imageLinks" ]                                         as? [[String: Any]],
              let imageUrl   = imageLinks.first?[ "href"       ]                                         as?   String
        else {
            return nil
        }

        var trackIds: [String] = []

        for item in included {
            if let trackId         = item                 [ "id"         ] as?   String       ,
               let trackAttributes = item                 [ "attributes" ] as?  [String: Any] ,
               let trackName       = trackAttributes      [ "title"      ] as?   String       ,
               let trackIsrc       = trackAttributes      [ "isrc"       ] as?   String       ,
               let trackImageLinks = trackAttributes      [ "imageLinks" ] as? [[String: Any]],
               let trackImageUrl   = trackImageLinks.last?[ "href"       ] as?   String {
                trackIds.append(trackId)
                Track.register(trackId, Track(name: trackName, imageUrl: trackImageUrl, isrc: trackIsrc))
            }
        }

        _storage[ id ] = PlayList(name: name, imageUrl: imageUrl, trackIds: trackIds)
        return get(_storage[ id ])
    }

    public static func playList(_ id: String) async -> PlayList? {
        return await _load(id) {
            $0
        }
    }

    public static func name(_ id: String) async -> String? {
        return await _load(id) {
            $0?.name
        }
    }

    public static func imageUrl(_ id: String) async -> String? {
        return await _load(id) {
            $0?.imageUrl
        }
    }

    public static func trackIds(_ id: String) async -> [String]? {
        return await _load(id) {
            $0?.trackIds
        }
    }
}
