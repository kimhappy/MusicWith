//
//  TimeFormat.swift
//  MusicWith
//
//  Created by kimhappy on 12/10/24.
//

func timeFormat(_ seconds: Int) -> String {
    let minute = seconds / 60
    let second = seconds % 60
    return String(format: "%d:%02d", minute, second)
}
