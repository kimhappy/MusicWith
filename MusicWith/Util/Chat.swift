//
//  Chat.swift
//  MusicWith
//
//  Created by 2020014975 on 11/3/24.
//

import SwiftUI
import Combine

struct Chat: Identifiable, Equatable {
    public var id      : String
    public var user    : String  // sending user
    public var text    : String? // text
    public var timeSong: Int?    // chatted playtime of the song
    public var parentId: String?
}
