//
// GameScreenLayout.swift
// LepreCON
//
// Shared layout constants for the three-zone game screen (HUD, board, dock).
//

import SwiftUI

enum GameScreenLayout {
    static let topBarHeight: CGFloat = 52
    static let hudToBoardGap: CGFloat = 4
    static let boardToDockGap: CGFloat = 4
    static let horizontalPadding: CGFloat = 12
    static let topPadding: CGFloat = 6
    static let bottomPadding: CGFloat = 8

    /// Bottom dock height (undo | D12 | hand).
    static let dockHeight: CGFloat = 120

    /// Height reserved for the board between HUD and dock.
    static func boardHeight(in screenHeight: CGFloat) -> CGFloat {
        let used = topPadding
            + topBarHeight
            + hudToBoardGap
            + boardToDockGap
            + dockHeight
            + bottomPadding
        return max(0, screenHeight - used)
    }

    static func bottomControlsHeight(for screenHeight: CGFloat) -> CGFloat {
        dockHeight
    }
}
