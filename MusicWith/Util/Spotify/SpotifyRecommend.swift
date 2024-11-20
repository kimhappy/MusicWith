//
//  SpotifyRecommend.swift
//  MusicWith
//
//  Created by user on 11/16/24.
//

class SpotifyRecommend {
    private let CHUNK_SIZE: Int = 15
    private var _playListStorage: [SpotifyPlayList] = []

    private static func queryEncode(_ str: String) -> String? {
        return str
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    func playList(idx: Int) async -> [SpotifyPlayList] {
        guard let json      = await getSpotifyJson("https://api.spotify.com/v1/browse/featured-playlists?offset=\(_playListStorage.count)&limit=\(CHUNK_SIZE)"),
              let playlists = json     [ "playlists" ] as?  [String: Any],
              let items     = playlists[ "items"     ] as? [[String: Any]] else {
            return _playListStorage
        }

        for item in items {
            guard let playListId = item[ "id"   ] as? String,
                  let name       = item[ "name" ] as? String  else {
                return _playListStorage
            }

            // 알고리즘 상 수정 필요? 현재는 중복 플레이리스트 막는 용도 -> 추후에 ID List Set을 만들어서 더 효율적으로 적용 가능할 듯
            if (_playListStorage.contains(where: { $0.playListId == playListId })) {
                return _playListStorage
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

        return _playListStorage
    }
}
