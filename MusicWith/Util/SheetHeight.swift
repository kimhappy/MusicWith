//
//  SheetHeight.swift
//  MusicWith
//
//  Created by kimhappy on 10/30/24.
//

import SwiftUI

enum SheetHeight {
    case mini
    case full

    public func detent() -> PresentationDetent {
        switch self {
        case .mini: PresentationDetent.fraction(0.15)
        case .full: PresentationDetent.large
        }
    }
}
