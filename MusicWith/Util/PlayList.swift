//
//  PlayList.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

// TODO: Implement with Spotify API
// TODO: Modify API
class PlayList {
    let id   : String
    let name : String
    let image: String
    var songs: [Song]

    static func myPlayLists() -> [PlayList] {
        return [
            PlayList(id: "1000"),
            PlayList(id: "1100"),
            PlayList(id: "1200"),
            PlayList(id: "1300"),
            PlayList(id: "1400"),
            PlayList(id: "1500"),
            PlayList(id: "1600"),
            PlayList(id: "1700"),
            PlayList(id: "1800"),
            PlayList(id: "1900"),
            PlayList(id: "2000"),
            PlayList(id: "2100"),
            PlayList(id: "2200"),
            PlayList(id: "2300"),
            PlayList(id: "2400"),
            PlayList(id: "2500"),
            PlayList(id: "2600"),
            PlayList(id: "2700"),
            PlayList(id: "2800"),
            PlayList(id: "2900"),
        ]
    }

    static func recommendPlayLists() -> [PlayList] {
        return [
            PlayList(id: "3000"),
            PlayList(id: "3100"),
            PlayList(id: "3200"),
            PlayList(id: "3300"),
            PlayList(id: "3400"),
            PlayList(id: "3500"),
            PlayList(id: "3600"),
            PlayList(id: "3700"),
            PlayList(id: "3800"),
            PlayList(id: "3900"),
            PlayList(id: "4000"),
            PlayList(id: "4100"),
            PlayList(id: "4200"),
            PlayList(id: "4300"),
            PlayList(id: "4400"),
            PlayList(id: "4500"),
            PlayList(id: "4600"),
            PlayList(id: "4700"),
            PlayList(id: "4800"),
            PlayList(id: "4900"),
        ]
    }

    init(id: String) {
        self.id    = id
        self.name  = "PlayList \(id)"
        self.image = "https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228"
        self.songs = [
            Song(id: "100"),
            Song(id: "110"),
            Song(id: "120"),
            Song(id: "130"),
            Song(id: "140"),
            Song(id: "150"),
            Song(id: "160"),
            Song(id: "170"),
            Song(id: "180"),
            Song(id: "190"),
            Song(id: "200"),
            Song(id: "210"),
            Song(id: "220"),
            Song(id: "230"),
            Song(id: "240"),
            Song(id: "250"),
            Song(id: "260"),
            Song(id: "270"),
            Song(id: "280"),
            Song(id: "290"),
        ]
    }

    func reserve(size: Int) {
        if songs.count >= size { return }

        for i in songs.count..<size {
            songs.append(Song(id: "\(i)"))
        }
    }
}
