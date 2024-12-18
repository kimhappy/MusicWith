//
//  ControlViewState.swift
//  MusicWith
//
//  Created by kimhappy on 12/10/24.
//

import SwiftUI

class ControlViewState: ObservableObject {
    static public var shared = ControlViewState()
    private init() {}

    @Published public var sheetHeight: SheetHeight = .mini
    @Published public var showSheet  : Bool        = false {
        didSet {
            if !showSheet {
                TrackPlayer.shared.stop()
            }
        }
    }
}
