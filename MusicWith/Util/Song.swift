//
//  Song.swift
//  MusicWith
//
//  Created by kimhappy on 10/29/24.
//

// TODO: Implement with Spotify API
class Song {
    let id      : String
    let title   : String
    let artist  : String
    let image   : String
    let url     : String
    
    init(id: String) {
        self.id       = id
        self.title    = "Song \(id)"
        self.artist   = "Artist \(id)"
        self.image    = "https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228"
        self.url      = "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3" // Testfile 이걸로 하니까 됩니다.
        
        // "https://www.dropbox.com/scl/fi/8jsve3il6x6f2zf9k9ekx/Ditto.wav?dl=1"
    }
}
