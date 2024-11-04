//
//  Chat.swift
//  MusicWith
//
//  Created by 2020014975 on 11/3/24.
//  chatting message data model define
import SwiftUI
import Combine


struct Chat: Identifiable {
    let id          = UUID()    // chat id
    let user        : String    // sending user
    let text        : String    // text
    let song        : String    // song with a chat
    let time_global : String    // global chatting time
    let time_song   : String    // chatted playtime of the song
    let isReply     : Bool      // true when this chat is reply
    let parentId    : UUID?
}
