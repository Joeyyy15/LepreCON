//
// GameScreenLayout.swift
// LepreCON
//
// Shared layout constants for the three-zone game screen (HUD, board, dock).
//

import SwiftUI

enum GameScreenLayout {
    /// Set true locally to outline HUD, board, and dock bounds.
    static let showLayoutDebug = false

    /// Asset aspect (2172×724) for top_bar and bottom_bar.
    static let barArtAspectRatio: CGFloat = 724.0 / 2172.0

    static let hudToBoardGap: CGFloat = 4
    static let boardToDockGap: CGFloat = 4
    /// Reserved strip between the board and dock for action feedback toasts.
    static let actionFeedbackSlotHeight: CGFloat = 36
    static let topPadding: CGFloat = -28
    static let bottomPadding: CGFloat = 0
    /// Inset from the safe-area edges to the shared foreground column (per side).
    static let horizontalInset: CGFloat = 6

    static let topBarInnerPadding: CGFloat = 4
    static let settingsButtonSize: CGFloat = 34
    static let dockInnerPadding: CGFloat = 4

    /// Bottom hand tray covers roughly the lower third of the gameplay screen.
    static let handTrayScreenHeightFraction: CGFloat = 1.0 / 3.0
    static let handTrayPreviewGemSize: CGFloat = 14
    static let handTrayDockPreviewMaxGems: Int = 3
    static let handTrayGridGemSize: CGFloat = 52
    static let handTrayGridCellMinHeight: CGFloat = 78

    /// Legacy fixed heights (previews); gameplay uses width-based sizing below.
    static let topBarHeight: CGFloat = 88
    static let dockHeight: CGFloat = 128

    static let minTopBarHeight: CGFloat = 108
    static let maxTopBarHeight: CGFloat = 126
    static let minDockHeight: CGFloat = 132
    static let maxDockHeight: CGFloat = 156

    /// Height that fits bar art to content width without squeezing the board.
    static func topBarHeight(forContentWidth width: CGFloat) -> CGFloat {
        barArtHeight(forWidth: width, min: minTopBarHeight, max: maxTopBarHeight)
    }

    static func dockHeight(forContentWidth width: CGFloat) -> CGFloat {
        barArtHeight(forWidth: width, min: minDockHeight, max: maxDockHeight)
    }

    private static func barArtHeight(forWidth width: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        let natural = width * barArtAspectRatio
        return Swift.min(Swift.max(natural, min), max)
    }

    /// Width shared by HUD, board, and dock inside the safe visible area.
    static func contentWidth(in geometry: GeometryProxy) -> CGFloat {
        let safeWidth = geometry.size.width
            - geometry.safeAreaInsets.leading
            - geometry.safeAreaInsets.trailing
        return max(0, safeWidth - horizontalInset * 2)
    }

    static func topContentPadding(in geometry: GeometryProxy) -> CGFloat {
        topPadding
    }

    static func bottomContentPadding(in geometry: GeometryProxy) -> CGFloat {
        bottomPadding
    }

    static func handTrayHeight(screenHeight: CGFloat) -> CGFloat {
        max(0, screenHeight * handTrayScreenHeightFraction)
    }
}

private struct GameScreenDebugBorderModifier: ViewModifier {
    let enabled: Bool
    let color: Color

    func body(content: Content) -> some View {
        if enabled {
            content.border(color.opacity(0.85), width: 1)
        } else {
            content
        }
    }
}

extension View {
    func gameScreenDebugBorder(_ color: Color = .red) -> some View {
        modifier(GameScreenDebugBorderModifier(enabled: GameScreenLayout.showLayoutDebug, color: color))
    }
}
