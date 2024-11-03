//
//  Chat.swift
//  MusicWith
//
//  Created by 2020014975 on 11/3/24.
//  chatting message data model define
import SwiftUI
import Combine


struct Chat: Identifiable {
    let id          : String    // chat id
    let user        : String    // sending user
    let text        : String    // text
    let song        : String    // song with a chat
    let time_global : String    // global chatting time
    let time_song   : String    // chatted playtime of the song
    
    init(id: String, user: String, text: String, song: String, time_global: String, time_song: String) {
        self.id          = id
        self.user        = user
        self.text        = text
        self.song        = song
        self.time_global = time_global
        self.time_song   = time_song
    }
}
