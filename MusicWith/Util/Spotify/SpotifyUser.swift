//
//  SpotifyUser.swift
//  MusicWith
//
//  Created by kimhappy on 11/5/24.
//

// https://developer.spotify.com/documentation/web-api/reference/get-current-users-profile
// https://developer.spotify.com/documentation/web-api/reference/get-users-profile
// https://developer.spotify.com/documentation/web-api/reference/get-a-list-of-current-users-playlists
// https://developer.spotify.com/documentation/web-api/reference/get-list-users-playlists
class SpotifyUser {
    private let CHUNK_SIZE: Int = 15 // 10으로 할 시 한 화면에 다 담겨져서 오류 생기는 듯?

    private var _storage        : [String: Any    ] = [:]
    private var _playListStorage: [SpotifyPlayList] = []

    let userId: String?

    init(userId: String?, name: String? = nil, imageUrl: String? = nil) {
        self.userId                 = userId
        self._storage[ "name"     ] = name
        self._storage[ "imageUrl" ] = imageUrl
    }

    private func load(key: String) async -> Any? {
        if let value = _storage[ key ] {
            return value
        }

        guard let json   = await SpotifyAPI.shared.getSpotifyAPIJson("https://api.spotify.com/v1/\(userId.map { "users/\($0)" } ?? "me")"),
              let name   = json[ "display_name" ] as?   String,
              let images = json[ "images"       ] as? [[String: Any]] else {
            return nil
        }

        let imageUrl = images.first?[ "url" ] as? String ?? ""

        _storage = [
            "name"    : name,
            "imageUrl": imageUrl
        ]

        return _storage[ key ]
    }

    func name() async -> String? {
        return await load(key: "name") as? String
    }

    func imageUrl() async -> String? {
        return await load(key: "imageUrl") as? String
    }

    func playList(idx: Int) async -> [SpotifyPlayList] {
        repeat {
            guard let json  = await SpotifyAPI.shared.getSpotifyAPIJson("https://api.spotify.com/v1/\(userId.map { "users/\($0)" } ?? "me")/playlists?offset=\(_playListStorage.count)&limit=\(CHUNK_SIZE)"),
                  let items = json[ "items" ] as? [[String: Any]] else {
                return []
            }

            // images 는 Null 값으로 전달 받는 경우 있어 밑에도 변경
            for item in items {
                guard let playListId = item[ "id"     ] as?   String,
                      let name       = item[ "name"   ] as?   String  else {
                    return []
                }

                // TODO: 알고리즘 상 수정 필요? 현재는 중복 플레이리스트 막는 용도 -> 추후에 ID List Set을 만들어서 더 효율적으로 적용 가능할 듯
                if (_playListStorage.contains(where: { $0.playListId == playListId })) {
                    break;
                }

                var imageUrls: [String] = []
                if let images = item[ "images" ] as? [[String : Any]] {
                    for image in images {
                        let url = image[ "url" ] as? String
                        imageUrls.append(url ?? "https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228")
                    }
                }
                else {
                    imageUrls.append("https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228")
                }

                _playListStorage.append(SpotifyPlayList(playListId: playListId, name: name, imageUrls: imageUrls))
            }
        } while (idx >= _playListStorage.count)
        return _playListStorage
    }
}
