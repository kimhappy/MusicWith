//
//  Chat.swift
//  MusicWith
//
//  Created by 2020014975 on 11/3/24.
//

import SwiftUI
import Combine

struct Chat: Identifiable {
    let id      : Int
    let user    : String // sending user
    let text    : String? // text
    let timeSong: Int? // chatted playtime of the song
    let parentId: Int?
}
