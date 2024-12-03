//
//  SpotifyTrack.swift
//  MusicWith
//
//  Created by kimhappy on 11/8/24.
//
import Foundation

// https://developer.spotify.com/documentation/web-api/reference/get-track
class SpotifyTrack {
    private var _storage: [String: Any] = [:]
    private var _lyric  : String?

    let trackId : String
    let imageURL: String? // storage 에 넣은 후 함수로 받아올 경우 무한 loading 이 걸림 => await 안 쓰게 구현시도
    let title   : String?

    init(trackId: String, name: String? = nil, artist: String? = nil, imageUrl: String? = nil, songUrl: String? = nil, lyric: String? = nil) {
        self.trackId                = trackId
        self._lyric                 = lyric
        self._storage[ "name"     ] = name
        self._storage[ "artist"   ] = artist
        self._storage[ "imageUrl" ] = imageUrl
        self._storage[ "songUrl"  ] = songUrl
        self.imageURL               = imageUrl
        self.title                  = name
    }

    private func load(key: String) async -> Any? {
        if let value = _storage[ key ] {
            return value
        }

        let url = "https://api.spotify.com/v1/tracks/\(trackId)"

        guard let json     = await SpotifyAPI.shared.getSpotifyAPIJson(url),
              let name     = json         [ "name"        ] as?   String       ,
              let artists  = json         [ "artists"     ] as? [[String: Any]],
              let album    = json         [ "album"       ] as?  [String: Any] ,
              let images   = album        [ "images"      ] as? [[String: Any]],
              let imageUrl = images.first?[ "url"         ] as?   String       ,
              let songUrl  = json         [ "preview_url" ] as?   String else { // 현재 preview_url 만 가능 확인, href, external_urls [spotify] 시도해 봄 -> 안 됨
            return nil
        }
        
        var artistNames: [String] = []

        for artist in artists {
            guard let name = artist[ "name" ] as? String else {
                return nil
            }

            artistNames.append(name)
        }

        _storage = [
            "name"    : name                               ,
            "artist"  : artistNames.joined(separator: ", "),
            "imageUrl": imageUrl                           ,
            "songUrl" : songUrl
        ]

        return _storage[ key ]
    }

    func name() async -> String? {
        return await load(key: "name") as? String
    }

    func artist() async -> String? {
        return await load(key: "artist") as? String
    }

    func imageUrl() async -> String? {
        return await load(key: "imageUrl") as? String
    }

    func songUrl() async -> String? {
        return await load(key: "songUrl") as? String
    }

    func lyric() async -> String? {
        if let lyric = _lyric {
            return lyric
        }

        guard let url = URL(string: "http://localhost:8000/lyrics?track_id=\(trackId)") else {
            return nil
        }

        let request = URLRequest(url: url)
        let data    = try? await URLSession.shared.data(for: request).0
        let json    = data.flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any] }

        guard let json  = json,
              let lines = json[ "lines" ] as? [[String: Any]] else {
            return nil
        }

        var lineMerged = ""

        for line in lines {
            guard let begin   = line[ "begin"   ] as? Int,
                  let content = line[ "content" ] as? String else {
                return nil
            }

            lineMerged += content + "\n"
        }

        _lyric = lineMerged
        return lineMerged
    }
}
