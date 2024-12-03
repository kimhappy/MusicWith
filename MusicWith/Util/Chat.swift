//
//  Chat.swift
//  MusicWith
//
//  Created by 2020014975 on 11/3/24.
//

import SwiftUI
import Combine

struct Chat: Identifiable, Equatable {
    let id      : String
    let user    : String // sending user
    var text    : String? // text
    var timeSong: Int? // chatted playtime of the song
    var parentId: String?
}
