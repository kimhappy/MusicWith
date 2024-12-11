//
//  Search.swift
//  MusicWith
//
//  Created by kimhappy on 12/9/24.
//

import Foundation

struct Search {
    public static func tracks(_ query: String) async -> [String]? {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url          = URL(string: "https://openapi.tidal.com/v2/searchresults/\(encodedQuery)/relationships/tracks?countryCode=KR&include=tracks.albums,tracks.artists"),
              let json         = await Query.getTidalJson(url),
              let included     = json[ "included" ] as? [[String: Any]]
        else {
            return nil
        }

        // TODO: to struct
        var tracks : [        [String]] = [ ] // id, name, isrc, artistId, albumId
        var artists: [String:  String ] = [:]
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
            let imageUrl = images [ albumId  ]
            Track.register(id, Track(name: name, imageUrl: imageUrl, artist: artist, isrc: isrc))
        }

        return tracks.map { $0[ 0 ] }
    }
}
