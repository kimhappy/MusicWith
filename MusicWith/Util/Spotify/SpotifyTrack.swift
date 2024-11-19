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
    let trackId: String
    let imageURL : String? // storage 에 넣은 후 함수로 받아올 경우 무한 loading 이 걸림 => await 안 쓰게 구현시도
    let title : String?
    
    init(trackId: String, name: String? = nil, imageUrl: String? = nil, songUrl: String? = nil, lyric: String? = nil) {
        self.trackId               = trackId
        self._storage[ "name"     ] = name
        self._storage[ "imageUrl" ] = imageUrl
        self._storage[ "songUrl"  ] = songUrl
        self._storage[ "lyric"    ] = lyric
        self.imageURL               = imageUrl
        self.title                  = name
    }

    private func load(key: String) async -> Any? {
        if let value = _storage[ key ] {
            return value
        }

        let url = "https://api.spotify.com/v1/tracks/\(trackId)"

        guard let json     = await getSpotifyJson(url),
              let name     = json         [ "name"   ] as?   String       ,
              let album    = json         [ "album"  ] as?  [String: Any] ,
              let images   = album        [ "images" ] as? [[String: Any]],
              let imageUrl = images.first?[ "url"    ] as?   String       ,
              let songUrl  = json         [ "preview_url"   ] as?   String else { // 현재 preview_url 만 가능 확인, href, external_urls [spotify] 시도해 봄 -> 안 됨
            return nil
        }

        _storage = [
            "name"    : name    ,
            "imageUrl": imageUrl,
            "songUrl" : songUrl ,
            "lyric"   : "This is Lyric of the song abcdefgasdfklshdfjwe;lfj;wejfj;walfjls;jdlfaskdjfkljslkdjfkl;sjlfj;sadk;fjsdjfk;asdklfj;sldfjk;asjdfkjsofhjwiefh;wehf;iwhe;fiuheiuwfhwejafljeaokfjojsf;sdljflsdjflsjafklsdjf;lsakfjsdkfj;laskdjfklsj;oewihfiuwheiu;fniweagwiokdfjhbjwiokfjnbhjwkfhbd hjdojhbwoijfb jeojkfnh"
        ]

        return _storage[ key ]
    }

    func name() async -> String? {
        return await load(key: "name") as? String
    }

    func imageUrl() async -> String? {
        return await load(key: "imageUrl") as? String
    }

    func songUrl() async -> String? {
        return await load(key: "songUrl") as? String
    }

    func lyric() async -> String? {
        return await load(key: "lyric") as? String
    }
}